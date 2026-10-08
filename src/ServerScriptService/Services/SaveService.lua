--[[
	SaveService
	-----------
	Branche le DataStore sur tous les GetSaveSnapshot/LoadFromSavedData deja
	prets dans StatsService, EconomyService, ChampionService, BannerService,
	SwordService, TitleService et ZoneService (GDD section 13).

	Responsabilites :
	- Charger les donnees d'un joueur a la connexion (avec retry)
	- Sauvegarder a la deconnexion, en autosave periodique, et a l'arret serveur
	- Schema versionne (SchemaVersion) pour permettre une migration future sans
	  casser les sauvegardes existantes

	IMPORTANT :
	- SERVEUR UNIQUEMENT.
	- Ce module ne cree AUCUNE donnee de jeu lui-meme : il ne fait que serialiser/
	  deserialiser ce que chaque service expose deja. Si tu ajoutes un nouveau
	  service avec un etat persistant, ajoute-le dans SERVICES ci-dessous et
	  c'est tout - rien d'autre a changer ici.
	- Retry avec backoff exponentiel sur les erreurs DataStore (throttling,
	  timeouts). Ne JAMAIS faire confiance a un GetAsync/UpdateAsync qui echoue
	  silencieusement : soit on retente, soit on bloque le join avec un message
	  clair plutot que de faire jouer quelqu'un sur des donnees vides par erreur.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local StatsService = require(script.Parent:WaitForChild("StatsService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local ChampionService = require(script.Parent:WaitForChild("ChampionService"))
local BannerService = require(script.Parent:WaitForChild("BannerService"))
local SwordService = require(script.Parent:WaitForChild("SwordService"))
local TitleService = require(script.Parent:WaitForChild("TitleService"))
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))

local SaveService = {}

local CURRENT_SCHEMA_VERSION = 1
local STORE_NAME = "AnimeLegend_PlayerData_v1"
local AUTO_SAVE_INTERVAL = 120 -- secondes
local MAX_RETRIES = 5
local RETRY_BASE_DELAY = 1 -- secondes, double a chaque tentative

local dataStore = DataStoreService:GetDataStore(STORE_NAME)

-- Services a persister : {nomLog, module}. Un seul endroit a modifier pour
-- brancher un nouveau service plus tard (SpecialService, PowerService, etc.)
local SERVICES = {
	{ key = "Stats", module = StatsService },
	{ key = "Economy", module = EconomyService },
	{ key = "Champions", module = ChampionService },
	{ key = "Banner", module = BannerService },
	{ key = "Sword", module = SwordService },
	{ key = "Title", module = TitleService },
	{ key = "Zone", module = ZoneService },
}

local PlayerLoaded = {} -- [UserId] = true une fois le chargement termine (evite de sauvegarder des donnees par defaut par-dessus une sauvegarde existante)
local PlayerSaving = {} -- [UserId] = true pendant une sauvegarde en cours (evite les sauvegardes concurrentes du meme joueur)

-- ============================================================
-- Retry generique
-- ============================================================

--[[
	Execute fn() avec retry + backoff exponentiel. Retourne (true, resultat)
	ou (false, dernierMessageErreur) si toutes les tentatives ont echoue.
]]
local function withRetry(fn, description: string)
	local lastError
	for attempt = 1, MAX_RETRIES do
		local success, result = pcall(fn)
		if success then
			return true, result
		end

		lastError = result
		warn(("SaveService: '%s' a echoue (tentative %d/%d): %s"):format(description, attempt, MAX_RETRIES, tostring(result)))

		if attempt < MAX_RETRIES then
			task.wait(RETRY_BASE_DELAY * (2 ^ (attempt - 1)))
		end
	end
	return false, lastError
end

-- ============================================================
-- Snapshot / migration
-- ============================================================

--- Rassemble les snapshots de tous les services en une seule table versionnee.
local function collectSnapshot(player)
	local snapshot = { SchemaVersion = CURRENT_SCHEMA_VERSION }
	for _, entry in ipairs(SERVICES) do
		snapshot[entry.key] = entry.module.GetSaveSnapshot(player)
	end
	return snapshot
end

--[[
	Migre une sauvegarde d'un ancien SchemaVersion vers CURRENT_SCHEMA_VERSION.
	Squelette pour l'instant (un seul schema existe) : ajoute un cas "if data.SchemaVersion == N then ... end"
	a chaque future migration, dans l'ordre, sans jamais modifier les cas precedents.
]]
local function migrateSchema(data)
	data.SchemaVersion = data.SchemaVersion or 0

	if data.SchemaVersion == CURRENT_SCHEMA_VERSION then
		return data
	end

	-- Exemple pour le futur :
	-- if data.SchemaVersion == 0 then
	--     data.SomeNewField = defaultValue
	--     data.SchemaVersion = 1
	-- end

	data.SchemaVersion = CURRENT_SCHEMA_VERSION
	return data
end

--- Applique un snapshot (deja migre) a tous les services.
local function applySnapshot(player, data)
	for _, entry in ipairs(SERVICES) do
		entry.module.LoadFromSavedData(player, data and data[entry.key])
	end
end

-- ============================================================
-- API publique
-- ============================================================

--[[
	A appeler sur Players.PlayerAdded, AVANT que le joueur puisse agir sur
	ses stats/argent/champions (bloque son spawn en attendant si besoin).
	Retourne true si des donnees existantes ont ete chargees, false si
	nouveau joueur (valeurs par defaut de chaque service).
]]
function SaveService.LoadPlayer(player): boolean
	local uid = player.UserId
	local success, data = withRetry(function()
		return dataStore:GetAsync("Player_" .. uid)
	end, "GetAsync pour " .. player.Name)

	if not success then
		-- Echec total apres tous les retries : on ne fait JAMAIS jouer quelqu'un
		-- sur des donnees vides sans le prevenir - c'est au caller (init.server.lua)
		-- de decider quoi faire (ex: kick avec message d'erreur).
		warn(("SaveService: chargement impossible pour %s, donnees NON appliquees"):format(player.Name))
		return false
	end

	if data then
		data = migrateSchema(data)
		applySnapshot(player, data)
		PlayerLoaded[uid] = true
		return true
	end

	-- Aucune sauvegarde existante : les services gardent leurs valeurs par defaut
	-- (chaque LoadFromSavedData(player, nil) gere deja ce cas).
	applySnapshot(player, nil)
	PlayerLoaded[uid] = true
	return false
end

--[[
	Sauvegarde immediate. SERVEUR UNIQUEMENT. Ne sauvegarde jamais un joueur
	dont le chargement n'a pas reussi (evite d'ecraser une sauvegarde valide
	avec des valeurs par defaut suite a un echec de GetAsync).
]]
function SaveService.SavePlayer(player): boolean
	local uid = player.UserId

	if not PlayerLoaded[uid] then
		warn(("SaveService: sauvegarde ignoree pour %s (jamais charge avec succes)"):format(player.Name))
		return false
	end

	if PlayerSaving[uid] then
		return false -- une sauvegarde est deja en cours pour ce joueur
	end
	PlayerSaving[uid] = true

	local snapshot = collectSnapshot(player)

	local success = withRetry(function()
		dataStore:UpdateAsync("Player_" .. uid, function()
			return snapshot
		end)
	end, "UpdateAsync pour " .. player.Name)

	PlayerSaving[uid] = false

	if not success then
		warn(("SaveService: sauvegarde ECHOUEE pour %s apres %d tentatives"):format(player.Name, MAX_RETRIES))
	end

	return success
end

--- A appeler sur Players.PlayerRemoving.
function SaveService.UnloadPlayer(player)
	local uid = player.UserId
	SaveService.SavePlayer(player)

	for _, entry in ipairs(SERVICES) do
		entry.module.ClearPlayer(player)
	end

	PlayerLoaded[uid] = nil
	PlayerSaving[uid] = nil
end

--[[
	A appeler depuis game:BindToClose dans init.server.lua. Sauvegarde tous
	les joueurs encore connectes avant l'arret du serveur. Roblox laisse
	generalement quelques dizaines de secondes max : on sauvegarde en serie
	(pas de task.spawn) pour etre sur que chaque joueur termine avant coupure.
]]
function SaveService.SaveAllForShutdown()
	for _, player in ipairs(Players:GetPlayers()) do
		SaveService.SavePlayer(player)
	end
end

--[[
	Lance la boucle d'autosave. A appeler UNE FOIS depuis init.server.lua
	au demarrage du serveur (ex: SaveService.StartAutoSaveLoop()).
]]
function SaveService.StartAutoSaveLoop()
	task.spawn(function()
		while true do
			task.wait(AUTO_SAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				SaveService.SavePlayer(player)
			end
		end
	end)
end

return SaveService