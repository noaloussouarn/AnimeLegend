--[[
	RemoteService
	-------------
	Point d'entree UNIQUE entre le client et tous les autres Services
	(GDD section 13 - "Security" : le client ne doit jamais etre autorite
	pour l'argent, les diamants, les stats, le resultat d'un tirage, etc).

	Responsabilites :
	- Creer les RemoteFunctions/RemoteEvents sous ReplicatedStorage.Remotes
	  (idempotent - pas besoin de les placer a la main dans Studio, Rojo n'a
	  qu'a synchroniser ce fichier)
	- Valider STRICTEMENT le type/la forme de chaque argument recu du client
	  avant de deleguer a un Service (le "player" vient toujours de Roblox
	  lui-meme via OnServerInvoke, jamais du payload envoye par le client)
	- Agreger l'etat complet du joueur en un seul GetPlayerState() pour
	  eviter de multiplier les allers-retours reseau depuis la future UI
	- Notifier le client des changements d'etat serveur (revenu passif,
	  tirage de banniere, titre reclame) via PlayerStateUpdated, au lieu
	  de forcer l'UI a faire du polling

	AUCUNE logique de jeu ici : ce module valide + delegue, un point c'est
	tout. Si un exploiteur envoie n'importe quoi, la pire consequence doit
	etre "requete refusee", jamais une erreur qui casse le serveur.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteNames = require(ReplicatedStorage.Data:WaitForChild("RemoteNames"))

local StatsService = require(script.Parent:WaitForChild("StatsService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local ChampionService = require(script.Parent:WaitForChild("ChampionService"))
local BannerService = require(script.Parent:WaitForChild("BannerService"))
local SwordService = require(script.Parent:WaitForChild("SwordService"))
local TitleService = require(script.Parent:WaitForChild("TitleService"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))

local RemoteService = {}

local PASSIVE_INCOME_INTERVAL = 10 -- secondes entre chaque tick de revenu passif du titre

local playerStateUpdatedEvent: RemoteEvent

-- ============================================================
-- Creation des instances Remote (idempotent : reutilise si deja presentes,
-- donc sans risque si le serveur redemarre ou si Init() est appele 2x)
-- ============================================================

local function getOrCreate(className: string, name: string, parent: Instance)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function createRemotes()
	local remotesFolder = getOrCreate("Folder", "Remotes", ReplicatedStorage)
	local functionsFolder = getOrCreate("Folder", "Functions", remotesFolder)
	local eventsFolder = getOrCreate("Folder", "Events", remotesFolder)

	local functions = {}
	for _, name in pairs(RemoteNames.Functions) do
		functions[name] = getOrCreate("RemoteFunction", name, functionsFolder)
	end

	local events = {}
	for _, name in pairs(RemoteNames.Events) do
		events[name] = getOrCreate("RemoteEvent", name, eventsFolder)
	end

	return functions, events
end

-- ============================================================
-- Validation utilitaire (jamais confiance dans un argument client)
-- ============================================================

local VALID_BANNER_PULLS = {
	BaseSingle = BannerService.PullBaseSingle,
	BaseTen = BannerService.PullBaseTen,
	PremiumSingle = BannerService.PullPremiumSingle,
	PremiumTen = BannerService.PullPremiumTen,
}

local function isNonEmptyString(value): boolean
	return type(value) == "string" and #value > 0
end

local function isPositiveInteger(value): boolean
	return type(value) == "number" and value == math.floor(value) and value > 0
end

-- ============================================================
-- Etat agrege (GetPlayerState)
-- ============================================================

--- Rassemble tout ce que la future UI a besoin d'afficher en un seul appel reseau.
function RemoteService.BuildPlayerState(player)
	local ownedChampions = ChampionService.GetSaveSnapshot(player).Owned

	return {
		Stats = StatsService.GetStats(player),
		PersonalMultiplier = StatsService.GetPersonalMultiplier(player),
		NextPersonalMultiplierCost = StatsService.GetNextPersonalMultiplierCost(player),
		CombatMaxHP = StatsService.GetCombatMaxHP(player),

		Money = EconomyService.GetMoney(player),
		Diamonds = EconomyService.GetDiamonds(player),

		OwnedChampions = ownedChampions,
		EquippedChampions = ChampionService.GetEquippedChampions(player),
		ChampionSlotCount = ChampionService.GetSlotCount(player),

		PityStatus = BannerService.GetPityStatus(player),

		EquippedSword = SwordService.GetEquippedSword(player),
		CurrentDojo = SwordService.GetCurrentDojo(player),
		IsEligibleForDojo2Trial = SwordService.IsEligibleForDojo2Trial(player),

		ActiveTitle = TitleService.GetActiveTitle(player),
		NextTitle = TitleService.GetNextTitle(player),

		UnlockedZoneIds = ZoneService.GetUnlockedZoneIds(player),
	}
end

local function pushPlayerState(player)
	if not playerStateUpdatedEvent then
		return
	end
	local success, state = pcall(RemoteService.BuildPlayerState, player)
	if success then
		playerStateUpdatedEvent:FireClient(player, state)
	else
		warn(("RemoteService: echec BuildPlayerState pour %s: %s"):format(player.Name, tostring(state)))
	end
end

-- ============================================================
-- Handlers (chaque OnServerInvoke re-verifie tout, jamais confiance au client)
-- ============================================================

local function bindHandlers(functions)
	functions[RemoteNames.Functions.GetPlayerState].OnServerInvoke = function(player)
		local success, state = pcall(RemoteService.BuildPlayerState, player)
		if not success then
			warn(("RemoteService: GetPlayerState a echoue pour %s: %s"):format(player.Name, tostring(state)))
			return false, "Erreur serveur"
		end
		return true, state
	end

	functions[RemoteNames.Functions.PersonalMultiplierUpgrade].OnServerInvoke = function(player)
		local success, result = EconomyService.TryPurchasePersonalMultiplierUpgrade(player)
		return success, result
	end

	functions[RemoteNames.Functions.TeleportToZone].OnServerInvoke = function(player, zoneId)
		if not isNonEmptyString(zoneId) then
			return false, "zoneId invalide"
		end
		local success, result = ZoneService.TryTeleportToZone(player, zoneId)
		return success, result
	end

	functions[RemoteNames.Functions.BannerPull].OnServerInvoke = function(player, pullType)
		local pullFunction = isNonEmptyString(pullType) and VALID_BANNER_PULLS[pullType]
		if not pullFunction then
			return false, "pullType invalide"
		end
		local success, result = pullFunction(player)
		if success then
			pushPlayerState(player) -- diamants + collection de Champions ont change
		end
		return success, result
	end

	functions[RemoteNames.Functions.EquipChampion].OnServerInvoke = function(player, championId, slotIndex)
		if not isPositiveInteger(championId) or not isPositiveInteger(slotIndex) then
			return false
		end
		return ChampionService.EquipChampion(player, championId, slotIndex)
	end

	functions[RemoteNames.Functions.EvolveChampionStar].OnServerInvoke = function(player, championId)
		if not isPositiveInteger(championId) or not ChampionService.Owns(player, championId) then
			return false, 0
		end
		local success, result = ChampionService.TryEvolveStar(player, championId)
		if success then
			pushPlayerState(player)
		end
		return success, result
	end

	functions[RemoteNames.Functions.ClaimNextTitle].OnServerInvoke = function(player)
		local newTitle = TitleService.ClaimNextTitle(player)
		if newTitle then
			pushPlayerState(player) -- multiplicateur d'argent / ¥ par minute a change
		end
		return newTitle
	end
end

-- ============================================================
-- Revenu passif (utilise EconomyService.GrantPassiveIncomeTick, qui existait
-- deja mais que rien n'appelait encore)
-- ============================================================

local function startPassiveIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(PASSIVE_INCOME_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				local moneyPerMinute = TitleService.GetMoneyPerMinute(player)
				if moneyPerMinute > 0 then
					EconomyService.GrantPassiveIncomeTick(player, moneyPerMinute, PASSIVE_INCOME_INTERVAL)
					pushPlayerState(player)
				end
			end
		end
	end)
end

-- ============================================================
-- API publique
-- ============================================================

--[[
	A appeler UNE FOIS depuis init.server.lua, au demarrage du serveur et
	AVANT que des joueurs ne se connectent (les Remotes doivent exister
	avant que le client ne fasse WaitForChild dessus).
]]
function RemoteService.Init()
	local functions, events = createRemotes()
	playerStateUpdatedEvent = events[RemoteNames.Events.PlayerStateUpdated]
	bindHandlers(functions)
	startPassiveIncomeLoop()
end

--- A appeler par init.server.lua juste apres SaveService.LoadPlayer, pour que le client recoive son etat initial sans avoir a le demander.
function RemoteService.PushInitialState(player)
	pushPlayerState(player)
end

return RemoteService