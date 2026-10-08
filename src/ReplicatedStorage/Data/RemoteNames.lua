--[[
	RemoteNames
	-----------
	Table centrale des noms de RemoteEvents/RemoteFunctions, partagee entre
	client et serveur pour eviter les "magic strings" dupliques (une faute
	de frappe cote client plante immediatement au lieu de silencieusement
	ne rien faire).

	RemoteService (serveur) cree les instances sous ReplicatedStorage.Remotes
	au demarrage. RemoteClient (client) les attend avec WaitForChild.
]]

local RemoteNames = {
	Functions = {
		GetPlayerState = "GetPlayerState",
		PersonalMultiplierUpgrade = "PersonalMultiplierUpgrade",
		TeleportToZone = "TeleportToZone",
		BannerPull = "BannerPull",
		EquipChampion = "EquipChampion",
		EvolveChampionStar = "EvolveChampionStar",
		ClaimNextTitle = "ClaimNextTitle",
	},
	Events = {
		PlayerStateUpdated = "PlayerStateUpdated",
	},
}

return RemoteNames