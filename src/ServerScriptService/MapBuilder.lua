--[[
	MapBuilder
	----------
	Genere une version "greybox" (blocs simples) des 100 zones de World 1
	(GDD section 3 + addendum section 7/12), directement compatible avec
	MobService (meme convention Workspace.Zones.<ZoneId>.SpawnPoints.SpawnN).

	CE QUE CE SCRIPT FAIT :
	- Cree un dossier Workspace.Zones.<ZoneId> par zone, avec :
	  Platform (sol), Landmark (bloc-reperage central), EntrySign (panneau
	  nom + requis + anime), TeleportAnchor (point utilise plus tard par le
	  vrai systeme de teleportation), SpawnPoints (10 points pour MobService)
	- Range les 100 zones en grille 10x10, dans l'ordre D01-30, F01-30, E01-30,
	  V01-05, A01-05 (= l'ordre exact des zones du GDD)
	- Colore Platform/Landmark selon StatType (juste pour s'y retrouver en test)
	- IDEMPOTENT : ignore une zone deja construite (verifie juste son dossier),
	  donc sans risque de l'appeler plusieurs fois au demarrage serveur

	CE QUE CE SCRIPT NE FAIT PAS (voir addendum section 8-11, a construire a la main) :
	- Aucun decor thematique reel (pas de village Konoha, pas de Seireitei...)
	- Aucun chemin physique entre zones (juste des plateformes isolees)
	- Aucune limite de monde/boundary
	Objectif : avoir un jeu testable de bout en bout (teleport/farm/kill/reward)
	AVANT que l'art final n'existe, exactement l'approche recommandee par le GDD
	("template reutilisable" avant de depenser le budget VFX/art).

	SERVEUR UNIQUEMENT. A appeler une fois au demarrage (voir init.server.lua) -
	idempotent, donc reste sans danger si le serveur redemarre.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = ReplicatedStorage:WaitForChild("Data")
local ZoneData = require(Data:WaitForChild("ZoneData"))
local NumberUtil = require(Data:WaitForChild("NumberUtil"))

local MapBuilder = {}

local GRID_COLUMNS = 10
local CELL_SPACING = 120 -- studs entre le centre de deux zones
local PLATFORM_SIZE = Vector3.new(60, 4, 60)
local LANDMARK_SIZE = Vector3.new(8, 30, 8)

-- Couleur greybox par StatType (juste pour s'y retrouver visuellement en test)
local STAT_COLORS = {
	Durability = BrickColor.new("Reddish brown"),
	Force = BrickColor.new("Really red"),
	Energy = BrickColor.new("Cyan"),
	Speed = BrickColor.new("New Yeller"),
	Agility = BrickColor.new("Earth green"),
}

local BOSS_GATE_COLOR = BrickColor.new("Really black")

-- ============================================================
-- Ordre exact des 100 zones (identique au GDD : D1-30, F1-30, E1-30, V1-5, A1-5)
-- ============================================================

local function buildZoneOrder()
	local order = {}
	for _, prefix in ipairs({ "D", "F", "E" }) do
		for i = 1, 30 do
			table.insert(order, ("%s%02d"):format(prefix, i))
		end
	end
	for _, prefix in ipairs({ "V", "A" }) do
		for i = 1, 5 do
			table.insert(order, ("%s%02d"):format(prefix, i))
		end
	end
	return order
end

-- ============================================================
-- Construction d'une zone
-- ============================================================

local function buildSpawnPoints(zoneFolder: Folder, centerPosition: Vector3)
	local spawnPointsFolder = Instance.new("Folder")
	spawnPointsFolder.Name = "SpawnPoints"
	spawnPointsFolder.Parent = zoneFolder

	-- Grille 2x5 des 10 points de spawn, repartie sur la plateforme.
	local index = 0
	for row = 0, 1 do
		for col = 0, 4 do
			index += 1
			local offset = Vector3.new((col - 2) * 8, 3, (row - 0.5) * 16)

			local spawnPart = Instance.new("Part")
			spawnPart.Name = "Spawn" .. index
			spawnPart.Size = Vector3.new(1, 1, 1)
			spawnPart.Transparency = 1
			spawnPart.CanCollide = false
			spawnPart.Anchored = true
			spawnPart.Position = centerPosition + offset
			spawnPart.Parent = spawnPointsFolder
		end
	end
end

local function buildEntrySign(zoneFolder: Folder, zone, centerPosition: Vector3)
	local signPart = Instance.new("Part")
	signPart.Name = "EntrySign"
	signPart.Size = Vector3.new(10, 6, 1)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.BrickColor = BrickColor.new("Institutional white")
	signPart.Position = centerPosition + Vector3.new(0, 5, -32)
	signPart.Parent = zoneFolder

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = signPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextColor3 = Color3.new(0, 0, 0)
	label.Font = Enum.Font.SourceSansBold

	local requiredText = zone.RequiredStat and NumberUtil.Format(zone.RequiredStat) or "?"
	label.Text = ("%s\n%s\nRequis: %s %s\nMult: x%s"):format(
		zone.Name,
		zone.Anime,
		requiredText,
		zone.StatType,
		NumberUtil.Format(zone.Multiplier)
	)
	label.Parent = surfaceGui
end

local function buildZone(zoneId: string, zone, zonesFolder: Folder, gridIndex: number)
	local existing = zonesFolder:FindFirstChild(zoneId)
	if existing then
		return -- deja construite, on ne touche a rien (idempotent)
	end

	local col = gridIndex % GRID_COLUMNS
	local row = math.floor(gridIndex / GRID_COLUMNS)
	local centerPosition = Vector3.new(col * CELL_SPACING, 0, row * CELL_SPACING)

	local zoneFolder = Instance.new("Folder")
	zoneFolder.Name = zoneId
	zoneFolder.Parent = zonesFolder

	local statColor = STAT_COLORS[zone.StatType] or BrickColor.new("Medium stone grey")

	local platform = Instance.new("Part")
	platform.Name = "Platform"
	platform.Size = PLATFORM_SIZE
	platform.Anchored = true
	platform.Position = centerPosition - Vector3.new(0, PLATFORM_SIZE.Y / 2, 0)
	platform.BrickColor = statColor
	platform.Parent = zoneFolder

	local landmark = Instance.new("Part")
	landmark.Name = "Landmark"
	landmark.Size = LANDMARK_SIZE
	landmark.Anchored = true
	landmark.Position = centerPosition + Vector3.new(0, LANDMARK_SIZE.Y / 2, 20)
	landmark.BrickColor = zone.BossGate and BOSS_GATE_COLOR or statColor
	landmark.Material = zone.BossGate and Enum.Material.Neon or Enum.Material.SmoothPlastic
	landmark.Parent = zoneFolder

	local teleportAnchor = Instance.new("Part")
	teleportAnchor.Name = "TeleportAnchor"
	teleportAnchor.Size = Vector3.new(4, 1, 4)
	teleportAnchor.Transparency = 1
	teleportAnchor.CanCollide = false
	teleportAnchor.Anchored = true
	teleportAnchor.Position = centerPosition + Vector3.new(0, 2, -20)
	teleportAnchor.Parent = zoneFolder

	buildEntrySign(zoneFolder, zone, centerPosition)
	buildSpawnPoints(zoneFolder, centerPosition)
end

-- ============================================================
-- API publique
-- ============================================================

--[[
	Construit (ou complete) les 100 zones en greybox. Idempotent : ne
	reconstruit jamais une zone qui a deja son dossier dans Workspace.Zones -
	donc sans danger de l'appeler a chaque demarrage serveur.
]]
function MapBuilder.BuildAllZones()
	local zonesFolder = Workspace:FindFirstChild("Zones")
	if not zonesFolder then
		zonesFolder = Instance.new("Folder")
		zonesFolder.Name = "Zones"
		zonesFolder.Parent = Workspace
	end

	local order = buildZoneOrder()
	local builtCount = 0

	for gridIndex, zoneId in ipairs(order) do
		local zone = ZoneData[zoneId]
		if zone then
			local alreadyExists = zonesFolder:FindFirstChild(zoneId) ~= nil
			buildZone(zoneId, zone, zonesFolder, gridIndex - 1)
			if not alreadyExists then
				builtCount += 1
			end
		else
			warn(("MapBuilder: zone '%s' absente de ZoneData, ignoree"):format(zoneId))
		end
	end

	print(("[Anime Legend] MapBuilder: %d nouvelle(s) zone(s) construite(s) (greybox)"):format(builtCount))
end

return MapBuilder