--[[
	StatsService
	------------
	Responsable de :
	- Stocker les 6 stats de farm du joueur (Durability, Force, Energy, Speed, Agility, Sword)
	- Le multiplicateur personnel (x1 au depart, double a chaque achat, cout double aussi)
	- Calculer les gains de farm : base x multiplicateur de zone x multiplicateur personnel
	  x bonus Champion x autres boosts eventuels (formule du GDD, section 2)
	- Convertir Durability -> HP de combat (echelle separee, voir section 10 du GDD)
	- Valider si un joueur remplit le requis d'entree d'une zone

	IMPORTANT - Autorite serveur :
	Ce module ne doit etre requis QUE depuis du code serveur (ServerScriptService).
	Le client ne doit jamais pouvoir appeler AddStat/ApplyPersonalMultiplierUpgrade
	directement : ca passera plus tard par des RemoteEvents valides par d'autres
	services (ex: MobService envoie les gains apres un kill valide cote serveur).

	STOCKAGE : ce module garde les stats en memoire (table indexee par UserId).
	C'est temporaire / testable des maintenant, mais destine a etre branche sur
	PlayerData/SaveService (DataStore) des que ce service existera. Voir
	StatsService.LoadFromSavedData / GetSaveSnapshot en bas de fichier, prevus
	pour cette integration future.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")

local NumberUtil = require(Data:WaitForChild("NumberUtil"))
local ZoneData = require(Data:WaitForChild("ZoneData"))

local StatsService = {}

-- Les 6 stats valides. Toute autre cle est refusee (protection contre les fautes de frappe/exploits).
local VALID_STATS = {
	Durability = true,
	Force = true,
	Energy = true,
	Speed = true,
	Agility = true,
	Sword = true,
}

-- Cout de base du multiplicateur personnel (voir GDD section 2.1) : 100 Y, double a chaque niveau.
local PERSONAL_MULT_BASE_COST = 100

-- Placeholder de conversion Durability -> HP de combat.
-- Le GDD (section 10) precise explicitement que la formule exacte reste a fixer
-- avant production. On utilise une echelle logarithmique pour eviter des HP absurdes
-- meme quand Durability atteint des valeurs enormes (1e40+) : c'est coherent avec la
-- regle du GDD "les PV/degats de combat utilisent une echelle independante et
-- beaucoup plus raisonnable". A retoucher librement, un seul endroit a changer.
local COMBAT_HP_BASE = 100
local COMBAT_HP_SCALE = 40

local PlayerStats = {} -- [UserId] = { Durability, Force, Energy, Speed, Agility, Sword, PersonalMultiplierLevel }

local function EnsurePlayerEntry(player)
	local uid = player.UserId
	if not PlayerStats[uid] then
		PlayerStats[uid] = {
			Durability = 0,
			Force = 0,
			Energy = 0,
			Speed = 0,
			Agility = 0,
			Sword = 0,
			PersonalMultiplierLevel = 0, -- 0 = x1 (voir GetPersonalMultiplier)
		}
	end
	return PlayerStats[uid]
end

--- Retourne une copie des stats actuelles du joueur.
function StatsService.GetStats(player)
	local entry = EnsurePlayerEntry(player)
	return {
		Durability = entry.Durability,
		Force = entry.Force,
		Energy = entry.Energy,
		Speed = entry.Speed,
		Agility = entry.Agility,
		Sword = entry.Sword,
	}
end

--- Retourne la valeur brute d'une seule stat.
function StatsService.GetStat(player, statType: string): number
	assert(VALID_STATS[statType], ("StatsService: stat invalide '%s'"):format(tostring(statType)))
	local entry = EnsurePlayerEntry(player)
	return entry[statType]
end

--[[
	Ajoute (ou retire, si amount < 0) une quantite a une stat de farm.
	SERVEUR UNIQUEMENT. Ne jamais appeler avec une valeur venant directement du client.
	Retourne la nouvelle valeur.
]]
function StatsService.AddStat(player, statType: string, amount: number): number
	assert(VALID_STATS[statType], ("StatsService: stat invalide '%s'"):format(tostring(statType)))
	assert(type(amount) == "number" and amount == amount, "StatsService: amount doit etre un nombre valide") -- amount==amount exclut NaN

	local entry = EnsurePlayerEntry(player)
	entry[statType] = math.max(0, entry[statType] + amount)
	return entry[statType]
end

--- x1, x2, x4, x8... (2^niveau). Niveau 0 = x1 au depart.
function StatsService.GetPersonalMultiplier(player): number
	local entry = EnsurePlayerEntry(player)
	return 2 ^ entry.PersonalMultiplierLevel
end

--- Cout du PROCHAIN niveau de multiplicateur personnel (100, 200, 400, 800 Y...).
function StatsService.GetNextPersonalMultiplierCost(player): number
	local entry = EnsurePlayerEntry(player)
	return PERSONAL_MULT_BASE_COST * (2 ^ entry.PersonalMultiplierLevel)
end

--[[
	Applique l'achat du prochain niveau de multiplicateur personnel.
	SERVEUR UNIQUEMENT, et seulement APRES qu'EconomyService ait valide et
	debite l'argent correspondant a GetNextPersonalMultiplierCost. Ce module
	ne gere pas l'argent lui-meme (separation des responsabilites, voir GDD
	section 13 - architecture).
]]
function StatsService.ApplyPersonalMultiplierUpgrade(player)
	local entry = EnsurePlayerEntry(player)
	entry.PersonalMultiplierLevel += 1
	return StatsService.GetPersonalMultiplier(player)
end

--[[
	Calcule le gain de farm pour un kill/tick dans une zone donnee, et l'ajoute
	directement a la bonne stat. Formule (GDD section 2) :
		Gain = base x multiplicateur de zone x multiplicateur personnel x bonus Champion x autres boosts

	- zoneId : ex "D15"
	- baseAmount : valeur de base du gain (couche d'equilibrage, voir NOTE plus bas)
	- championBonusMultiplier : optionnel, fourni plus tard par ChampionService (defaut 1)
	- extraMultiplier : optionnel, pour d'autres boosts futurs (gamepass, evenement...) (defaut 1)

	NOTE sur baseAmount : le GDD ne verrouille pas de valeur de base universelle
	("les valeurs exactes de base restent une couche d'implementation/equilibrage").
	C'est donc a MobService/QuestService de decider combien de "base" un kill ou
	un tick de farm represente, et de le passer ici.
]]
function StatsService.ApplyFarmGain(
	player,
	zoneId: string,
	baseAmount: number,
	championBonusMultiplier: number?,
	extraMultiplier: number?
): number
	local zone = ZoneData[zoneId]
	assert(zone, ("StatsService: zone inconnue '%s'"):format(tostring(zoneId)))

	local personalMultiplier = StatsService.GetPersonalMultiplier(player)
	local championMult = championBonusMultiplier or 1
	local extraMult = extraMultiplier or 1

	local gain = baseAmount * zone.Multiplier * personalMultiplier * championMult * extraMult

	return StatsService.AddStat(player, zone.StatType, gain)
end

--[[
	Est-ce que le joueur remplit le requis d'entree de la zone (peut y farmer) ?
	Retourne true/false. Les zones Speed/Agility n'ont pas de requis documente
	dans le GDD (RequiredStat = nil) -> considere comme toujours accessible pour
	l'instant, a corriger quand ces seuils seront definis.
]]
function StatsService.MeetsZoneRequirement(player, zoneId: string): boolean
	local zone = ZoneData[zoneId]
	assert(zone, ("StatsService: zone inconnue '%s'"):format(tostring(zoneId)))

	if zone.RequiredStat == nil then
		return true
	end

	local currentStat = StatsService.GetStat(player, zone.StatType)
	return currentStat >= zone.RequiredStat
end

--[[
	Durability -> HP de combat (placeholder, voir commentaire COMBAT_HP_* en haut
	du fichier). Echelle logarithmique pour rester "raisonnable" meme a tres
	haute Durability, conformement a la regle du GDD.
]]
function StatsService.GetCombatMaxHP(player): number
	local durability = StatsService.GetStat(player, "Durability")
	return COMBAT_HP_BASE + COMBAT_HP_SCALE * math.log(durability + 1, 10)
end

--[[
	Snapshot serialisable des stats, pense pour SaveService (DataStore) plus tard.
	Ne fait aucune I/O ici - juste la forme des donnees a sauvegarder.
]]
function StatsService.GetSaveSnapshot(player)
	local entry = EnsurePlayerEntry(player)
	return {
		Durability = entry.Durability,
		Force = entry.Force,
		Energy = entry.Energy,
		Speed = entry.Speed,
		Agility = entry.Agility,
		Sword = entry.Sword,
		PersonalMultiplierLevel = entry.PersonalMultiplierLevel,
	}
end

--- Restaure les stats d'un joueur depuis un snapshot sauvegarde (SaveService appellera ca au join).
function StatsService.LoadFromSavedData(player, savedData)
	local entry = EnsurePlayerEntry(player)
	for stat in pairs(VALID_STATS) do
		entry[stat] = (savedData and savedData[stat]) or 0
	end
	entry.PersonalMultiplierLevel = (savedData and savedData.PersonalMultiplierLevel) or 0
end

--- A appeler quand un joueur quitte, pour liberer la memoire (une fois SaveService branche, sauver avant).
function StatsService.ClearPlayer(player)
	PlayerStats[player.UserId] = nil
end

return StatsService
