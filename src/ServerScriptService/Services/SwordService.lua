--[[
	SwordService
	------------
	Gere la progression Sword (GDD section 3.4/3.5) :
	- Le joueur possede/equipe UNE epee a la fois, dans l'ordre de SwordData (1 a 30)
	- Deux dojos : le dojo 1 (accessible) puis le dojo 2 (legendaire), separes par
	  une epreuve reussie uniquement avec l'epee + les Pouvoirs d'epee autorises
	- Une epee ne possede QUE nom/univers/multiplicateur - ses attaques vivent
	  ailleurs (Specials/Pouvoirs), donc ce service ne gere aucun combat
	- Le stat de farm "Sword" (voir StatsService) progresse via ce multiplicateur,
	  exactement comme un multiplicateur de zone pour les autres stats

	IMPORTANT :
	- Seul le serveur doit appeler AdvanceToNextSword / CompleteDojo2Trial.
	  Ce sont des recompenses de quete, jamais un choix libre du client.
	- Le nombre d'epees necessaires avant l'epreuve du dojo 2 n'est PAS verrouille
	  dans le GDD ("apres plusieurs epees" - pas de chiffre precis). DOJO_1_SWORD_COUNT
	  ci-dessous est un placeholder a ajuster, un seul endroit a changer.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local SwordData = require(Data:WaitForChild("SwordData"))

local StatsService = require(script.Parent:WaitForChild("StatsService"))

local SwordService = {}

-- Placeholder : nombre d'epees a obtenir dans le dojo 1 avant de pouvoir tenter
-- l'epreuve d'acces au dojo 2. A retoucher librement.
local DOJO_1_SWORD_COUNT = 15

local PlayerSwordData = {} -- [UserId] = { EquippedSwordIndex, Dojo2Unlocked }

local function EnsurePlayerEntry(player)
	local uid = player.UserId
	if not PlayerSwordData[uid] then
		PlayerSwordData[uid] = {
			EquippedSwordIndex = 1, -- commence avec l'epee 1 : Katana d'Entrainement
			Dojo2Unlocked = false,
		}
	end
	return PlayerSwordData[uid]
end

--- Index de l'epee actuellement equipee (1 a 30).
function SwordService.GetEquippedSwordIndex(player): number
	return EnsurePlayerEntry(player).EquippedSwordIndex
end

--- Donnees completes de l'epee actuellement equipee (Name, Anime, Multiplier).
function SwordService.GetEquippedSword(player)
	local index = SwordService.GetEquippedSwordIndex(player)
	return SwordData[index]
end

--- 1 (dojo accessible) ou 2 (dojo legendaire), selon si l'epreuve a ete reussie.
function SwordService.GetCurrentDojo(player): number
	return EnsurePlayerEntry(player).Dojo2Unlocked and 2 or 1
end

--- Le joueur a-t-il assez d'epees pour tenter l'epreuve du dojo 2 ?
function SwordService.IsEligibleForDojo2Trial(player): boolean
	local entry = EnsurePlayerEntry(player)
	return not entry.Dojo2Unlocked and entry.EquippedSwordIndex >= DOJO_1_SWORD_COUNT
end

--[[
	Valide la reussite de l'epreuve d'acces au dojo 2. SERVEUR UNIQUEMENT,
	a appeler seulement apres que le combat d'epreuve (gere par CombatService,
	pas encore construit) ait ete valide comme gagne.
	Retourne true si applique, false si le joueur n'etait pas eligible.
]]
function SwordService.CompleteDojo2Trial(player): boolean
	if not SwordService.IsEligibleForDojo2Trial(player) then
		return false
	end
	EnsurePlayerEntry(player).Dojo2Unlocked = true
	return true
end

--[[
	Recompense de quete de dojo : fait passer le joueur a l'epee suivante.
	SERVEUR UNIQUEMENT, a appeler depuis QuestService apres validation de la quete.
	Si la prochaine epee necessite le dojo 2 et qu'il n'est pas debloque, refuse
	(il faut d'abord reussir l'epreuve via CompleteDojo2Trial).
	Retourne la nouvelle epee equipee, ou nil si refuse/deja au max.
]]
function SwordService.AdvanceToNextSword(player)
	local entry = EnsurePlayerEntry(player)

	if entry.EquippedSwordIndex >= #SwordData then
		return nil -- deja a la derniere epee (30)
	end

	local nextIndex = entry.EquippedSwordIndex + 1
	if nextIndex > DOJO_1_SWORD_COUNT and not entry.Dojo2Unlocked then
		return nil -- epreuve du dojo 2 pas encore reussie
	end

	entry.EquippedSwordIndex = nextIndex
	return SwordData[nextIndex]
end

--[[
	Applique un gain de farm sur le stat "Sword", en utilisant le multiplicateur
	de l'epee actuellement equipee (meme logique que StatsService.ApplyFarmGain,
	mais avec le multiplicateur d'epee a la place du multiplicateur de zone).
]]
function SwordService.ApplySwordFarmGain(
	player,
	baseAmount: number,
	championBonusMultiplier: number?,
	extraMultiplier: number?
): number
	local sword = SwordService.GetEquippedSword(player)
	local personalMultiplier = StatsService.GetPersonalMultiplier(player)
	local championMult = championBonusMultiplier or 1
	local extraMult = extraMultiplier or 1

	local gain = baseAmount * sword.Multiplier * personalMultiplier * championMult * extraMult

	return StatsService.AddStat(player, "Sword", gain)
end

--- Snapshot serialisable, pense pour SaveService plus tard.
function SwordService.GetSaveSnapshot(player)
	local entry = EnsurePlayerEntry(player)
	return {
		EquippedSwordIndex = entry.EquippedSwordIndex,
		Dojo2Unlocked = entry.Dojo2Unlocked,
	}
end

function SwordService.LoadFromSavedData(player, savedData)
	local entry = EnsurePlayerEntry(player)
	entry.EquippedSwordIndex = (savedData and savedData.EquippedSwordIndex) or 1
	entry.Dojo2Unlocked = (savedData and savedData.Dojo2Unlocked) or false
end

function SwordService.ClearPlayer(player)
	PlayerSwordData[player.UserId] = nil
end

return SwordService