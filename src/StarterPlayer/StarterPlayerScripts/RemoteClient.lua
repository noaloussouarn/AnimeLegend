--[[
	RemoteClient
	------------
	Wrapper client autour des Remotes crees par RemoteService (serveur).
	Aucune UI ici - juste des fonctions propres a appeler depuis les futurs
	scripts d'interface (GDD section 11, UIService pas encore construit).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Data:WaitForChild("RemoteNames"))

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local functionsFolder = remotesFolder:WaitForChild("Functions")
local eventsFolder = remotesFolder:WaitForChild("Events")

local function getFunction(name: string): RemoteFunction
	return functionsFolder:WaitForChild(name) :: RemoteFunction
end

local function getEvent(name: string): RemoteEvent
	return eventsFolder:WaitForChild(name) :: RemoteEvent
end

local RemoteClient = {}

-- ============================================================
-- Etat joueur
-- ============================================================

--- (success, state) - state complet : stats, argent, champions, titre, etc.
function RemoteClient.GetPlayerState()
	return getFunction(RemoteNames.Functions.GetPlayerState):InvokeServer()
end

--[[
	S'abonne aux mises a jour serveur (revenu passif, tirage, titre reclame...).
	callback recoit directement le state complet. Retourne la connexion (Disconnect() si besoin).
]]
function RemoteClient.OnPlayerStateUpdated(callback: (any) -> ())
	return getEvent(RemoteNames.Events.PlayerStateUpdated).OnClientEvent:Connect(callback)
end

-- ============================================================
-- Actions
-- ============================================================

--- (success, nouveauMultiplicateurOuCoutRequis)
function RemoteClient.RequestPersonalMultiplierUpgrade()
	return getFunction(RemoteNames.Functions.PersonalMultiplierUpgrade):InvokeServer()
end

--- (success, zoneDataOuRaison)
function RemoteClient.RequestTeleportToZone(zoneId: string)
	return getFunction(RemoteNames.Functions.TeleportToZone):InvokeServer(zoneId)
end

--- pullType: "BaseSingle" | "BaseTen" | "PremiumSingle" | "PremiumTen". (success, resultatsOuCout)
function RemoteClient.RequestBannerPull(pullType: string)
	return getFunction(RemoteNames.Functions.BannerPull):InvokeServer(pullType)
end

--- boolean
function RemoteClient.RequestEquipChampion(championId: number, slotIndex: number)
	return getFunction(RemoteNames.Functions.EquipChampion):InvokeServer(championId, slotIndex)
end

--- (success, nouvellesEtoilesOuFragmentsManquants)
function RemoteClient.RequestEvolveChampionStar(championId: number)
	return getFunction(RemoteNames.Functions.EvolveChampionStar):InvokeServer(championId)
end

--- Le nouveau titre, ou nil si refuse.
function RemoteClient.RequestClaimNextTitle()
	return getFunction(RemoteNames.Functions.ClaimNextTitle):InvokeServer()
end

return RemoteClient