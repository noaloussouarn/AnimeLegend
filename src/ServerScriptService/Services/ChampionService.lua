--[[
	ChampionService
	---------------
	Gere la collection de Champions d'un joueur (GDD section 7) :
	- Possession, niveau, XP, etoiles (evolution via doublons/fragments)
	- Calcul du bonus reel de stats a un niveau donne (10% -> 100% du potentiel)
	- Slot(s) equipe(s) (1 par defaut, 2e slot vendable via gamepass)
	- Activation des passifs (manuelle/auto/conditionnelle - voir note plus bas)

	Ne gere PAS : les tirages de bannieres (BannerService, a construire),
	l'argent/diamants (EconomyService), le combat reel (CombatService).

	Formule de bonus (GDD section 7) :
		Bonus = BonusMax x (0.10 + 0.90 x (niveau-1)/99)
	Niveau 1 = 10% du potentiel, niveau 100 = 100% du potentiel.

	XP requise par niveau : le GDD ne verrouille PAS de table precise, seulement
	un objectif ("vise environ 10M XP cumules au niveau 100"). CumulativeXPForLevel
	ci-dessous est une courbe quadratique calibree pour atteindre exactement 10M
	au niveau 100 - PLACEHOLDER a retoucher librement, un seul endroit a changer.

	SERVEUR UNIQUEMENT.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local ChampionData = require(Data:WaitForChild("ChampionData"))

local ChampionService = {}

local MAX_LEVEL = 100
local TARGET_CUMULATIVE_XP_AT_MAX = 10_000_000 -- objectif du GDD ("~10M XP cumules au niveau 100")

-- Cout en Fragments pour faire evoluer un Champion d'une etoile (par palier de rarete,
-- voir GDD section 8 "Doublons"). Valeurs verrouillees du GDD (rarete 1-10).
local FRAGMENT_COST_PER_RARITY = {
	[1] = 5,    [2] = 10,   [3] = 25,   [4] = 50,   [5] = 100,
	[6] = 250,  [7] = 500,  [8] = 1000, [9] = 2500, [10] = 5000,
}

local MAX_STARS = 5

local PlayerChampions = {} -- [UserId] = { [championId] = { Level, XP, Stars, Fragments } }
local PlayerEquipped = {} -- [UserId] = { SlotCount, EquippedIds = {championId, ...} }

local function EnsureOwnedTable(player)
	local uid = player.UserId
	if not PlayerChampions[uid] then
		PlayerChampions[uid] = {}
	end
	return PlayerChampions[uid]
end

local function EnsureEquippedEntry(player)
	local uid = player.UserId
	if not PlayerEquipped[uid] then
		PlayerEquipped[uid] = { SlotCount = 1, EquippedIds = {} }
	end
	return PlayerEquipped[uid]
end

-- ============================================================
-- Progression XP / Niveau
-- ============================================================

--- XP cumulee totale necessaire pour ATTEINDRE ce niveau (1 = 0 XP).
function ChampionService.CumulativeXPForLevel(level: number): number
	if level <= 1 then
		return 0
	end
	local ratio = (level - 1) / (MAX_LEVEL - 1)
	return TARGET_CUMULATIVE_XP_AT_MAX * (ratio ^ 2)
end

--- XP necessaire pour passer du niveau actuel au suivant (niveau+1).
function ChampionService.XPToNextLevel(level: number): number
	if level >= MAX_LEVEL then
		return math.huge
	end
	return ChampionService.CumulativeXPForLevel(level + 1) - ChampionService.CumulativeXPForLevel(level)
end

--- Le pourcentage du potentiel (0.10 a 1.0) qu'un Champion de ce niveau exprime.
function ChampionService.GetBonusRatioAtLevel(level: number): number
	level = math.clamp(level, 1, MAX_LEVEL)
	return 0.10 + 0.90 * (level - 1) / (MAX_LEVEL - 1)
end

-- ============================================================
-- Possession
-- ============================================================

--- Le joueur possede-t-il ce Champion ?
function ChampionService.Owns(player, championId: number): boolean
	return EnsureOwnedTable(player)[championId] ~= nil
end

--[[
	Ajoute un Champion a la collection du joueur. SERVEUR UNIQUEMENT, a appeler
	depuis le futur BannerService apres un tirage reussi.
	Si le joueur possede deja ce Champion, convertit en Fragments (doublon,
	voir GDD section 8) plutot que de dupliquer l'entree.
]]
function ChampionService.GrantChampion(player, championId: number)
	local champion = ChampionData[championId]
	assert(champion, ("ChampionService: champion inconnu id=%s"):format(tostring(championId)))

	local owned = EnsureOwnedTable(player)

	if owned[championId] then
		-- Doublon -> Fragments (la valeur exacte de fragments par doublon est geree
		-- par BannerService/BannerData, pas ici - ce service se contente de stocker
		-- les fragments une fois attribues, voir AddFragments).
		return false -- pas un nouveau champion
	end

	owned[championId] = {
		Level = 1,
		XP = 0,
		Stars = 1,
		Fragments = 0,
	}
	return true
end

--- Ajoute des Fragments a un Champion possede (venant d'un doublon ou d'une conversion).
function ChampionService.AddFragments(player, championId: number, amount: number)
	local owned = EnsureOwnedTable(player)
	local entry = owned[championId]
	assert(entry, "ChampionService: le joueur ne possede pas ce champion")
	entry.Fragments += amount
end

--[[
	Tente de faire evoluer un Champion d'une etoile en consommant les Fragments
	necessaires (cout selon la rarete, voir FRAGMENT_COST_PER_RARITY).
	Retourne (true, nouvellesEtoiles) ou (false, fragmentsManquants).
]]
function ChampionService.TryEvolveStar(player, championId: number): (boolean, number)
	local champion = ChampionData[championId]
	local owned = EnsureOwnedTable(player)
	local entry = owned[championId]
	assert(champion and entry, "ChampionService: champion invalide ou non possede")

	if entry.Stars >= MAX_STARS then
		return false, 0
	end

	local cost = FRAGMENT_COST_PER_RARITY[champion.Rarity]
	if entry.Fragments < cost then
		return false, cost - entry.Fragments
	end

	entry.Fragments -= cost
	entry.Stars += 1
	return true, entry.Stars
end

--[[
	Ajoute de l'XP a un Champion possede et applique les montees de niveau
	en cascade (si assez d'XP pour plusieurs niveaux d'un coup).
	Retourne le nouveau niveau.
]]
function ChampionService.AddChampionXP(player, championId: number, amount: number): number
	local owned = EnsureOwnedTable(player)
	local entry = owned[championId]
	assert(entry, "ChampionService: le joueur ne possede pas ce champion")

	entry.XP += amount

	while entry.Level < MAX_LEVEL do
		local xpNeeded = ChampionService.CumulativeXPForLevel(entry.Level + 1)
		if entry.XP >= xpNeeded then
			entry.Level += 1
		else
			break
		end
	end

	return entry.Level
end

--[[
	Valeur REELLE d'une stat pour ce Champion au niveau actuel (MaxStat x ratio
	de niveau). Retourne nil si cette stat n'est pas definie pour ce Champion
	(cas Kiba/Happy/Kabuto/Chopper, stats non verrouillees).
]]
function ChampionService.GetEffectiveStat(player, championId: number, statName: string): number?
	local champion = ChampionData[championId]
	local owned = EnsureOwnedTable(player)
	local entry = owned[championId]
	assert(champion and entry, "ChampionService: champion invalide ou non possede")

	local maxStat = champion.MaxStats[statName]
	if maxStat == nil then
		return nil
	end

	return maxStat * ChampionService.GetBonusRatioAtLevel(entry.Level)
end

-- ============================================================
-- Equipement (slots)
-- ============================================================

--- Nombre de slots d'equipement disponibles (1 par defaut, 2 avec le gamepass).
function ChampionService.GetSlotCount(player): number
	return EnsureEquippedEntry(player).SlotCount
end

--- A appeler par EconomyService/MonetizationService apres achat confirme du gamepass.
function ChampionService.UnlockSecondSlot(player)
	EnsureEquippedEntry(player).SlotCount = 2
end

--- Liste des championId actuellement equipes (dans l'ordre des slots).
function ChampionService.GetEquippedChampions(player): { number }
	return EnsureEquippedEntry(player).EquippedIds
end

--[[
	Equipe un Champion possede dans un slot donne (1 ou 2). Refuse si le slot
	demande depasse GetSlotCount, ou si le Champion n'est pas possede.
	Retourne true/false.
]]
function ChampionService.EquipChampion(player, championId: number, slotIndex: number): boolean
	if not ChampionService.Owns(player, championId) then
		return false
	end

	local equipped = EnsureEquippedEntry(player)
	if slotIndex > equipped.SlotCount then
		return false
	end

	equipped.EquippedIds[slotIndex] = championId
	return true
end

--[[
	Declenche le passif d'un Champion equipe. NOTE IMPORTANTE : le GDD dit que
	l'activation peut etre "manuelle, automatique ou conditionnelle selon le
	passif" mais NE PRECISE PAS ce classement pour chaque Champion individuellement
	- c'est une decision de design de combat encore a prendre. Cette fonction
	fournit juste le point d'entree ; CombatService (a construire) devra decider
	QUAND l'appeler pour chaque passif (bouton manuel affiche, trigger auto sur
	un evenement de combat, etc).
]]
function ChampionService.TriggerPassive(player, championId: number)
	local champion = ChampionData[championId]
	assert(champion, "ChampionService: champion inconnu")
	-- Le comportement reel du passif (degats, buff, invocation...) est un sujet
	-- CombatService/VFX, pas ChampionService. On expose juste le nom ici.
	return champion.Passif
end

-- ============================================================
-- Sauvegarde
-- ============================================================

function ChampionService.GetSaveSnapshot(player)
	local owned = EnsureOwnedTable(player)
	local equipped = EnsureEquippedEntry(player)

	local ownedSnapshot = {}
	for championId, entry in pairs(owned) do
		ownedSnapshot[championId] = {
			Level = entry.Level,
			XP = entry.XP,
			Stars = entry.Stars,
			Fragments = entry.Fragments,
		}
	end

	return {
		Owned = ownedSnapshot,
		SlotCount = equipped.SlotCount,
		EquippedIds = equipped.EquippedIds,
	}
end

function ChampionService.LoadFromSavedData(player, savedData)
	local owned = EnsureOwnedTable(player)
	local equipped = EnsureEquippedEntry(player)

	if savedData and savedData.Owned then
		for championIdStr, entry in pairs(savedData.Owned) do
			local championId = tonumber(championIdStr) or championIdStr
			owned[championId] = {
				Level = entry.Level or 1,
				XP = entry.XP or 0,
				Stars = entry.Stars or 1,
				Fragments = entry.Fragments or 0,
			}
		end
	end

	equipped.SlotCount = (savedData and savedData.SlotCount) or 1
	equipped.EquippedIds = (savedData and savedData.EquippedIds) or {}
end

function ChampionService.ClearPlayer(player)
	PlayerChampions[player.UserId] = nil
	PlayerEquipped[player.UserId] = nil
end

return ChampionService