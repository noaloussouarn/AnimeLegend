--[[
	TitleService
	------------
	Gere la progression des titres/classes (GDD section 6) :
	- Les titres sont lineaires et obligatoires dans l'ordre, jamais de skip
	- Chaque titre demande exactement 3 conditions de stats (voir TitleData)
	- Le titre actif donne un multiplicateur d'argent ET un revenu ¥/minute
	- Le joueur garde tous les titres obtenus ; le titre actif = le plus haut obtenu

	Ce service fait le pont entre StatsService (verifier les conditions) et
	EconomyService (qui recoit le multiplicateur/¥ par minute en parametre,
	voir EconomyService.GrantMobMoneyReward / GrantPassiveIncomeTick).

	SERVEUR UNIQUEMENT. ClaimNextTitle ne doit jamais etre appelable
	directement par le client sans validation serveur des conditions
	(c'est deja le cas ici : la fonction revalide tout elle-meme).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local TitleData = require(Data:WaitForChild("TitleData"))

local StatsService = require(script.Parent:WaitForChild("StatsService"))

local TitleService = {}

local PlayerTitles = {} -- [UserId] = { ActiveTitleIndex } (0 = aucun titre obtenu)

local function EnsurePlayerEntry(player)
	local uid = player.UserId
	if not PlayerTitles[uid] then
		PlayerTitles[uid] = {
			ActiveTitleIndex = 0,
		}
	end
	return PlayerTitles[uid]
end

--- 0 si aucun titre obtenu, sinon l'index du titre actif (le plus haut obtenu).
function TitleService.GetActiveTitleIndex(player): number
	return EnsurePlayerEntry(player).ActiveTitleIndex
end

--- Donnees completes du titre actif, ou nil si aucun titre obtenu.
function TitleService.GetActiveTitle(player)
	local index = TitleService.GetActiveTitleIndex(player)
	if index == 0 then
		return nil
	end
	return TitleData[index]
end

--- Multiplicateur d'argent actuel (1 par defaut si aucun titre obtenu).
function TitleService.GetMoneyMultiplier(player): number
	local title = TitleService.GetActiveTitle(player)
	return title and title.MoneyMultiplier or 1
end

--- ¥/minute actuel (0 par defaut si aucun titre obtenu).
function TitleService.GetMoneyPerMinute(player): number
	local title = TitleService.GetActiveTitle(player)
	return title and title.MoneyPerMinute or 0
end

--- Le prochain titre a obtenir, ou nil si le joueur a deja le dernier (20).
function TitleService.GetNextTitle(player)
	local nextIndex = TitleService.GetActiveTitleIndex(player) + 1
	return TitleData[nextIndex]
end

--[[
	Est-ce que le joueur remplit les 3 conditions du PROCHAIN titre ?
	Retourne true/false, et en 2e valeur la liste des conditions non remplies
	(utile pour l'UI : afficher ce qu'il manque).
]]
function TitleService.MeetsNextTitleConditions(player): (boolean, { any })
	local nextTitle = TitleService.GetNextTitle(player)
	if not nextTitle then
		return false, {}
	end

	local missing = {}
	for _, condition in ipairs(nextTitle.Conditions) do
		local current = StatsService.GetStat(player, condition.Stat)
		if current < condition.Amount then
			table.insert(missing, condition)
		end
	end

	return #missing == 0, missing
end

--[[
	Tente de faire passer le joueur au titre suivant. Revalide les conditions
	cote serveur (ne fait jamais confiance a un etat client). Retourne le
	nouveau titre si applique, sinon nil (pas eligible ou deja au dernier titre).
]]
function TitleService.ClaimNextTitle(player)
	local nextTitle = TitleService.GetNextTitle(player)
	if not nextTitle then
		return nil -- deja au titre 20 (max actuel)
	end

	local meets = TitleService.MeetsNextTitleConditions(player)
	if not meets then
		return nil
	end

	local entry = EnsurePlayerEntry(player)
	entry.ActiveTitleIndex = nextTitle.Id
	return nextTitle
end

-- ============================================================
-- Sauvegarde
-- ============================================================

function TitleService.GetSaveSnapshot(player)
	return {
		ActiveTitleIndex = TitleService.GetActiveTitleIndex(player),
	}
end

function TitleService.LoadFromSavedData(player, savedData)
	local entry = EnsurePlayerEntry(player)
	entry.ActiveTitleIndex = (savedData and savedData.ActiveTitleIndex) or 0
end

function TitleService.ClearPlayer(player)
	PlayerTitles[player.UserId] = nil
end

return TitleService