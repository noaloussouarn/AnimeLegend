--[[
	MobService
	----------
	Boucle de jeu principale : spawn des 10 mobs par zone (GDD section 4),
	combat au clic, mort -> recompenses (argent, diamant, XP Champion), respawn.

	REGLE VERROUILLEE DU GDD (section 1) :
	"Les ennemis de farm donnent de l'argent, une chance de Diamant Brillant et
	de l'XP Champion, mais jamais directement de statistiques de farm."
	Ce service NE TOUCHE JAMAIS StatsService. Le farm de stats (Durability/
	Force/Energy) est une mecanique separee, pas encore definie (confirme).

	MODELE PLACEHOLDER :
	Aucun mesh/asset anime n'existe encore. Ce service genere un mob "boite"
	minimal (Humanoid + Part + BillboardGui nom) a partir de MobData, pour que
	la boucle combat/kill/reward/respawn soit testable des maintenant. Remplace
	buildPlaceholderModel() par un vrai mesh plus tard - rien d'autre a changer.

	CONVENTION WORKSPACE ATTENDUE (a construire zone par zone, cote build) :
		Workspace
		  Zones
		    <ZoneId>              (ex: "D01")
		      SpawnPoints
		        Spawn1 .. Spawn10  (BasePart, CanCollide=false, Transparency=1)

	Une zone sans dossier SpawnPoints est simplement ignoree (aucune erreur) -
	permet de construire les zones progressivement sans casser le serveur.
	Si tu ajoutes des SpawnPoints pendant un test en cours, rappelle juste
	MobService.SpawnAllBuiltZones() depuis la command bar.

	SERVEUR UNIQUEMENT.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = ReplicatedStorage:WaitForChild("Data")
local MobData = require(Data:WaitForChild("MobData"))
local ZoneData = require(Data:WaitForChild("ZoneData"))

local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local TitleService = require(script.Parent:WaitForChild("TitleService"))
local ChampionService = require(script.Parent:WaitForChild("ChampionService"))

local MobService = {}

local RESPAWN_DELAY = 8 -- secondes avant qu'un mob tue ne reapparaisse
local BASE_ATTACK_DAMAGE = 5 -- GDD section 10, verrouille : "coup de poing/pied/epee = 5 degats de base"
local ATTACK_COOLDOWN = 0.5 -- anti-exploit : limite le rythme de clic par joueur
local CLICK_MAX_DISTANCE = 15 -- studs

local mobsFolder = Instance.new("Folder")
mobsFolder.Name = "Mobs"
mobsFolder.Parent = Workspace

-- ActiveMobs[zoneId][spawnIndex] = { Model, Humanoid, MobId, Dead }
local ActiveMobs = {}

local PlayerLastAttack = {} -- [UserId] = os.clock() du dernier coup porte (anti-exploit)

-- ============================================================
-- Modele placeholder
-- ============================================================

local function buildPlaceholderModel(mobData, spawnIndex: number)
	local model = Instance.new("Model")
	model.Name = ("%s_%d"):format(mobData.Name, spawnIndex)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Anchored = false
	root.CanCollide = true
	root.BrickColor = BrickColor.random()
	root.Parent = model
	model.PrimaryPart = root

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = mobData.PV
	humanoid.Health = mobData.PV
	humanoid.Parent = model

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = CLICK_MAX_DISTANCE
	clickDetector.Parent = root

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Text = mobData.Name
	nameLabel.Parent = billboard

	model.Parent = mobsFolder

	return model, humanoid, clickDetector
end

-- ============================================================
-- Recompenses (GDD section 4.2 + 7 : argent, diamant, XP Champion)
-- ============================================================

local function grantMobRewards(player, mobId: number)
	local mob = MobData[mobId]

	local moneyMultiplier = TitleService.GetMoneyMultiplier(player)
	EconomyService.GrantMobMoneyReward(player, mobId, moneyMultiplier)

	-- NOTE : le GDD donne la CHANCE de drop un Diamant mais ne precise pas la
	-- QUANTITE par drop reussi. 1 Diamant par reussite est un placeholder
	-- raisonnable a ajuster librement, un seul endroit a changer.
	if math.random() * 100 <= mob.DiamondChance then
		EconomyService.AddDiamonds(player, 1)
	end

	for _, championId in ipairs(ChampionService.GetEquippedChampions(player)) do
		if championId then
			ChampionService.AddChampionXP(player, championId, mob.ChampionXP)
		end
	end
end

-- ============================================================
-- Spawn / respawn
-- ============================================================

local function spawnOneMob(zoneId: string, spawnIndex: number, spawnPart: BasePart, mobId: number)
	local mobData = MobData[mobId]
	local model, humanoid, clickDetector = buildPlaceholderModel(mobData, spawnIndex)
	model:PivotTo(CFrame.new(spawnPart.Position))

	ActiveMobs[zoneId][spawnIndex] = {
		Model = model,
		Humanoid = humanoid,
		MobId = mobId,
		Dead = false,
	}

	clickDetector.MouseClick:Connect(function(player)
		MobService.AttackMob(player, zoneId, spawnIndex)
	end)

	humanoid.Died:Connect(function()
		MobService.HandleMobDeath(zoneId, spawnIndex)
	end)
end

--- Spawn les (jusqu'a 10) mobs d'une zone, si son dossier SpawnPoints existe dans Workspace.
function MobService.SpawnZoneMobs(zoneId: string)
	local zone = ZoneData[zoneId]
	if not zone or not zone.MobId then
		return -- zone inconnue ou sans mob assigne (Speed/Agility non definies dans le GDD)
	end

	local zonesFolder = Workspace:FindFirstChild("Zones")
	local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(zoneId)
	local spawnPointsFolder = zoneFolder and zoneFolder:FindFirstChild("SpawnPoints")
	if not spawnPointsFolder then
		return -- zone pas encore construite cote build, on ignore silencieusement
	end

	ActiveMobs[zoneId] = ActiveMobs[zoneId] or {}

	for spawnIndex = 1, 10 do
		local spawnPart = spawnPointsFolder:FindFirstChild("Spawn" .. spawnIndex)
		if spawnPart and not ActiveMobs[zoneId][spawnIndex] then
			spawnOneMob(zoneId, spawnIndex, spawnPart, zone.MobId)
		end
	end
end

--- Lance le spawn pour TOUTES les zones qui ont deja un dossier SpawnPoints dans Workspace.
function MobService.SpawnAllBuiltZones()
	for zoneId in pairs(ZoneData) do
		MobService.SpawnZoneMobs(zoneId)
	end
end

local function respawnAfterDelay(zoneId: string, spawnIndex: number, spawnPart: BasePart, mobId: number)
	task.delay(RESPAWN_DELAY, function()
		-- La zone/le spawn point peut avoir disparu entre-temps (rebuild) - on verifie.
		if ActiveMobs[zoneId] and spawnPart.Parent then
			spawnOneMob(zoneId, spawnIndex, spawnPart, mobId)
		end
	end)
end

-- ============================================================
-- Combat
-- ============================================================

--[[
	Point d'entree du combat au clic. Appele DIRECTEMENT par le ClickDetector
	cote serveur - le "player" vient de l'evenement MouseClick lui-meme,
	jamais d'un payload client, donc impossible a usurper pour un autre joueur.
]]
function MobService.AttackMob(player, zoneId: string, spawnIndex: number)
	if not ZoneService.IsZoneUnlocked(player, zoneId) then
		return -- pas le niveau requis pour farmer cette zone (GDD section 3)
	end

	local uid = player.UserId
	local now = os.clock()
	if PlayerLastAttack[uid] and now - PlayerLastAttack[uid] < ATTACK_COOLDOWN then
		return -- anti-exploit : clic trop rapide
	end
	PlayerLastAttack[uid] = now

	local entry = ActiveMobs[zoneId] and ActiveMobs[zoneId][spawnIndex]
	if not entry or entry.Dead then
		return
	end

	entry.Humanoid:TakeDamage(BASE_ATTACK_DAMAGE)

	if entry.Humanoid.Health <= 0 and not entry.Dead then
		entry.Dead = true
		grantMobRewards(player, entry.MobId)
	end
end

--- Appele par Humanoid.Died (mort par n'importe quelle cause) : nettoyage + respawn.
function MobService.HandleMobDeath(zoneId: string, spawnIndex: number)
	local entry = ActiveMobs[zoneId] and ActiveMobs[zoneId][spawnIndex]
	if not entry then
		return
	end
	entry.Dead = true

	local zonesFolder = Workspace:FindFirstChild("Zones")
	local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(zoneId)
	local spawnPointsFolder = zoneFolder and zoneFolder:FindFirstChild("SpawnPoints")
	local spawnPart = spawnPointsFolder and spawnPointsFolder:FindFirstChild("Spawn" .. spawnIndex)
	local mobId = entry.MobId

	if entry.Model then
		entry.Model:Destroy()
	end
	ActiveMobs[zoneId][spawnIndex] = nil

	if spawnPart then
		respawnAfterDelay(zoneId, spawnIndex, spawnPart, mobId)
	end
end

return MobService