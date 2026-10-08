--[[
	init.client.lua
	----------------
	Point d'entree client d'Anime Legend. Require RemoteClient et fait un
	premier appel de test pour verifier que le lien client-serveur fonctionne.
	L'UI reelle (GDD section 11) branchera dessus plus tard.
]]

local Players = game:GetService("Players")

local RemoteClient = require(script.Parent:WaitForChild("RemoteClient"))

local localPlayer = Players.LocalPlayer

local success, state = RemoteClient.GetPlayerState()
if success then
	print(("[Anime Legend] Etat recu pour %s : %d Y, %d Diamants"):format(
		localPlayer.Name,
		state.Money,
		state.Diamonds
	))
else
	warn("[Anime Legend] Echec GetPlayerState : " .. tostring(state))
end

RemoteClient.OnPlayerStateUpdated(function(state)
	print(("[Anime Legend] State mis a jour : %d Y"):format(state.Money))
end)
