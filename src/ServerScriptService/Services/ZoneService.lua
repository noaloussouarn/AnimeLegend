--[[
	ZoneService
	-----------
	Gere l'acces aux 100 zones de farm (GDD section 3 + addendum section 7) :
	- Verifie si un joueur peut entrer/farmer une zone (requis de stat + boss gate)
	- Fournit la liste des zones "debloquees" pour la Boussole (elle ne revele
	  pas tout d'un coup, voir GDD section 11)
	- Valide les demandes de teleportation (la teleportation physique/CFrame
	  sera geree plus tard par un MapService/UI, ce service ne fait QUE valider)
	- Gere le verrou des zones Dn/Fn/En30 derriere Imu/Frieza/Yhwach

	IMPORTANT :
	- L'acces a une zone est calcule dynamiquement depuis les stats actuelles
	  du joueur (via StatsService) plutot que stocke - pas besoin de sauvegarder
	  un etat "debloque" separe, ca reste toujours coherent avec la progression.
	- Les defaites de boss (Imu/Frieza/Yhwach) sont stockees ICI temporairement
	  en attendant un vrai BossService. Quand BossService existera, il pourra
	  appeler ZoneService.SetBossDefeated directement - rien d'autre a changer.
	- SERVEUR UNIQUEMENT. La teleportation reelle ne doit jamais se faire sur
	  la seule foi d'une demande client sans repasser par TryTeleportToZone.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local ZoneData = require(Data:WaitForChild("ZoneData"))

local StatsService = require(script.Parent:WaitForChild("StatsService"))

local ZoneService = {}

local PlayerBossDefeats = {} -- [UserId] = { Imu = bool, Frieza = bool, Yhwach = bool }

local function EnsureBossEntry(player)
	local uid = player.UserId
	if not PlayerBossDefeats[uid] then
		PlayerBossDefeats[uid] = { Imu = false, Frieza = false, Yhwach = false }
	end
	return PlayerBossDefeats[uid]
end

--- Donnees brutes d'une zone (passthrough pratique, evite d'importer ZoneData partout).
function ZoneService.GetZoneData(zoneId: string)
	return ZoneData[zoneId]
end

--- Le joueur a-t-il vaincu ce boss ? bossName = "Imu" / "Frieza" / "Yhwach".
function ZoneService.IsBossDefeated(player, bossName: string): boolean
	return EnsureBossEntry(player)[bossName] == true
end

--[[
	Marque un boss comme vaincu pour ce joueur. SERVEUR UNIQUEMENT,
	a appeler uniquement depuis un futur BossService/CombatService
	APRES validation reelle du combat (jamais depuis une demande client directe).
]]
function ZoneService.SetBossDefeated(player, bossName: string)
	assert(
		bossName == "Imu" or bossName == "Frieza" or bossName == "Yhwach",
		("ZoneService: boss invalide '%s'"):format(tostring(bossName))
	)
	EnsureBossEntry(player)[bossName] = true
end

--[[
	Est-ce que le joueur peut entrer/farmer cette zone ? Combine :
	1) Le requis de stat (via StatsService.MeetsZoneRequirement)
	2) Le boss gate de la zone si elle en a un (BossGate = "Imu"/"Frieza"/"Yhwach")
]]
function ZoneService.IsZoneUnlocked(player, zoneId: string): boolean
	local zone = ZoneData[zoneId]
	assert(zone, ("ZoneService: zone inconnue '%s'"):format(tostring(zoneId)))

	if not StatsService.MeetsZoneRequirement(player, zoneId) then
		return false
	end

	if zone.BossGate and not ZoneService.IsBossDefeated(player, zone.BossGate) then
		return false
	end

	return true
end

--[[
	Kaguya (boss final, hors zones classiques) ne se debloque qu'une fois
	les 3 branches terminales (D30/F30/E30) accomplies, cf GDD section 5.2.
]]
function ZoneService.CanAccessKaguya(player): boolean
	return ZoneService.IsBossDefeated(player, "Imu")
		and ZoneService.IsBossDefeated(player, "Frieza")
		and ZoneService.IsBossDefeated(player, "Yhwach")
end

--[[
	Liste des zones actuellement debloquees pour ce joueur (pour la Boussole).
	Retourne un tableau de zoneId, tries pour un affichage stable (D avant F
	avant E avant V avant A, puis par numero).
]]
function ZoneService.GetUnlockedZoneIds(player): { string }
	local unlocked = {}
	for zoneId in pairs(ZoneData) do
		if ZoneService.IsZoneUnlocked(player, zoneId) then
			table.insert(unlocked, zoneId)
		end
	end
	table.sort(unlocked)
	return unlocked
end

--[[
	Valide une demande de teleportation vers une zone.
	Retourne (true, zoneData) si autorise, (false, raison) sinon.
	Ne deplace PAS physiquement le joueur - ca reste au MapService/UI d'utiliser
	le TeleportAnchor de la zone pour positionner le HumanoidRootPart une fois
	que ce service dit "true".
]]
function ZoneService.TryTeleportToZone(player, zoneId: string): (boolean, any)
	local zone = ZoneData[zoneId]
	if not zone then
		return false, "Zone inconnue"
	end

	if not ZoneService.IsZoneUnlocked(player, zoneId) then
		return false, "Zone non debloquee"
	end

	return true, zone
end

--- Nettoyage a la deconnexion (une fois SaveService branche : sauver avant).
function ZoneService.ClearPlayer(player)
	PlayerBossDefeats[player.UserId] = nil
end

--- Snapshot pour SaveService plus tard.
function ZoneService.GetSaveSnapshot(player)
	local entry = EnsureBossEntry(player)
	return {
		Imu = entry.Imu,
		Frieza = entry.Frieza,
		Yhwach = entry.Yhwach,
	}
end

function ZoneService.LoadFromSavedData(player, savedData)
	local entry = EnsureBossEntry(player)
	entry.Imu = (savedData and savedData.Imu) or false
	entry.Frieza = (savedData and savedData.Frieza) or false
	entry.Yhwach = (savedData and savedData.Yhwach) or false
end

return ZoneService