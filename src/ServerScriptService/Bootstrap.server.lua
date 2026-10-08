--[[
	Bootstrap.server.lua
	---------------------
	Point d'entree serveur d'Anime Legend. Demarre RemoteService (cree les
	Remotes), construit la map greybox, spawn les mobs, puis branche le
	cycle de vie joueur sur SaveService.
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local RemoteService = require(Services:WaitForChild("RemoteService"))
local SaveService = require(Services:WaitForChild("SaveService"))
local MobService = require(Services:WaitForChild("MobService"))
local MapBuilder = require(ServerScriptService:WaitForChild("MapBuilder"))

-- Les Remotes doivent exister avant qu'un client ne fasse WaitForChild dessus.
RemoteService.Init()

-- Construit la map greybox (idempotent) puis spawn les mobs dessus.
MapBuilder.BuildAllZones()
MobService.SpawnAllBuiltZones()

Players.PlayerAdded:Connect(function(player)
	local loadedExisting = SaveService.LoadPlayer(player)
	print(("[Anime Legend] %s connecte (%s)"):format(
		player.Name,
		loadedExisting and "sauvegarde chargee" or "nouveau joueur"
	))
	RemoteService.PushInitialState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	SaveService.UnloadPlayer(player)
	print(("[Anime Legend] %s deconnecte, sauvegarde effectuee"):format(player.Name))
end)

game:BindToClose(function()
	print("[Anime Legend] Arret serveur, sauvegarde de tous les joueurs...")
	SaveService.SaveAllForShutdown()
end)

SaveService.StartAutoSaveLoop()

print("=== Anime Legend - Serveur demarre ===")