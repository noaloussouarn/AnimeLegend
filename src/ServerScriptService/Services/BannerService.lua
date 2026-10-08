--[[
	BannerService
	-------------
	Gere les tirages de Champions (GDD section 8) :
	- Base Banner (73 champions, rarity 1-8) et Premium Banner (30 champions, rarity 8-10)
	- Pity independant par palier (voir BannerData)
	- Doublons -> Fragments (via ChampionService.AddFragments)
	- Debite les Diamants Brillants via EconomyService avant de tirer

	Separation des responsabilites : ce service NE stocke PAS les Champions
	possedes (ChampionService s'en charge) et NE gere PAS l'argent/diamants
	(EconomyService s'en charge) - il fait juste le pont entre les deux au
	moment du tirage.

	SERVEUR UNIQUEMENT.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local ChampionData = require(Data:WaitForChild("ChampionData"))
local BannerData = require(Data:WaitForChild("BannerData"))

local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local ChampionService = require(script.Parent:WaitForChild("ChampionService"))

local BannerService = {}

-- Pools precalcules : liste des championId par rarete, separes Base/Premium.
local function buildPool(isPremium: boolean)
	local pool = {} -- [rarity] = { championId, championId, ... }
	for id, champion in pairs(ChampionData) do
		if champion.IsPremium == isPremium then
			pool[champion.Rarity] = pool[champion.Rarity] or {}
			table.insert(pool[champion.Rarity], id)
		end
	end
	return pool
end

local BASE_POOL = buildPool(false)
local PREMIUM_POOL = buildPool(true)

local PlayerPity = {} -- [UserId] = { Base = { [rarity] = count }, Premium = { [rarity] = count } }

local function EnsurePityEntry(player)
	local uid = player.UserId
	if not PlayerPity[uid] then
		local base, premium = {}, {}
		for _, tier in ipairs(BannerData.BASE_PITY) do
			base[tier.rarity] = 0
		end
		for _, tier in ipairs(BannerData.PREMIUM_PITY) do
			premium[tier.rarity] = 0
		end
		PlayerPity[uid] = { Base = base, Premium = premium }
	end
	return PlayerPity[uid]
end

-- Tirage pondere : weights = { [rarity] = poids }. Retourne une rarity.
local function rollWeightedRarity(weights): number
	local total = 0
	for _, w in pairs(weights) do
		total += w
	end

	local roll = math.random() * total
	local cumulative = 0
	for rarity, w in pairs(weights) do
		cumulative += w
		if roll <= cumulative then
			return rarity
		end
	end

	-- Filet de securite (erreurs d'arrondi flottant) : renvoie la plus basse rarete du pool.
	local lowest = math.huge
	for rarity in pairs(weights) do
		lowest = math.min(lowest, rarity)
	end
	return lowest
end

--[[
	Applique la logique de pity : incremente tous les compteurs, determine si
	un palier est atteint (force alors AU MOINS cette rarete), sinon tire au hasard.
	Reset uniquement les compteurs des paliers satisfaits par le resultat final.
	pityTiers = BannerData.BASE_PITY ou PREMIUM_PITY ; pityCounters = la sous-table du joueur.
]]
local function rollRarityWithPity(weights, pityTiers, pityCounters): number
	-- 1) incremente tous les compteurs de pity de ce banner
	for _, tier in ipairs(pityTiers) do
		pityCounters[tier.rarity] += 1
	end

	-- 2) le pity le plus eleve atteint force le resultat (garantie la plus forte gagne)
	local forcedRarity = nil
	for _, tier in ipairs(pityTiers) do
		if pityCounters[tier.rarity] >= tier.count then
			if forcedRarity == nil or tier.rarity > forcedRarity then
				forcedRarity = tier.rarity
			end
		end
	end

	local resultRarity
	if forcedRarity then
		resultRarity = forcedRarity
	else
		resultRarity = rollWeightedRarity(weights)
	end

	-- 3) reset les compteurs des paliers satisfaits par ce resultat (<=resultRarity)
	for _, tier in ipairs(pityTiers) do
		if resultRarity >= tier.rarity then
			pityCounters[tier.rarity] = 0
		end
	end

	return resultRarity
end

--[[
	Effectue UN tirage sur le pool/poids donnes, applique le gain (nouveau
	Champion ou Fragments si doublon), retourne le resultat detaille.
]]
local function performSinglePull(player, pool, weights, pityTiers, pityCounters)
	local rarity = rollRarityWithPity(weights, pityTiers, pityCounters)

	local candidates = pool[rarity]
	assert(candidates and #candidates > 0, ("BannerService: pool vide pour rarity %d"):format(rarity))
	local championId = candidates[math.random(1, #candidates)]

	local isNew = ChampionService.GrantChampion(player, championId)
	local fragmentsGranted = 0

	if not isNew then
		fragmentsGranted = BannerData.FRAGMENT_VALUE_PER_DUPLICATE[rarity]
		ChampionService.AddFragments(player, championId, fragmentsGranted)
	end

	return {
		ChampionId = championId,
		ChampionName = ChampionData[championId].Name,
		Rarity = rarity,
		IsNew = isNew,
		FragmentsGranted = fragmentsGranted,
	}
end

--[[
	Fonction generique de tirage (base ou premium, x1 ou x10).
	Debite les Diamants d'abord ; si le solde est insuffisant, ne tire rien.
	Retourne (true, { resultats... }) ou (false, coutRequis).
]]
local function pull(player, isPremium: boolean, pullCount: number)
	local pool = isPremium and PREMIUM_POOL or BASE_POOL
	local weights = isPremium and BannerData.PREMIUM_RARITY_WEIGHTS or BannerData.BASE_RARITY_WEIGHTS
	local pityTiers = isPremium and BannerData.PREMIUM_PITY or BannerData.BASE_PITY
	local costTable = isPremium and BannerData.COSTS.Premium or BannerData.COSTS.Base
	local cost = (pullCount == 10) and costTable.Ten or costTable.Single

	local success = EconomyService.SpendDiamonds(player, cost)
	if not success then
		return false, cost
	end

	local pityEntry = isPremium and EnsurePityEntry(player).Premium or EnsurePityEntry(player).Base

	local results = {}
	for _ = 1, pullCount do
		table.insert(results, performSinglePull(player, pool, weights, pityTiers, pityEntry))
	end

	return true, results
end

--- Tirage x1 sur le Base Banner. Cout : 10 Diamants.
function BannerService.PullBaseSingle(player)
	return pull(player, false, 1)
end

--- Tirage x10 sur le Base Banner. Cout : 100 Diamants.
function BannerService.PullBaseTen(player)
	return pull(player, false, 10)
end

--- Tirage x1 sur le Premium Banner. Cout : 500 Diamants.
function BannerService.PullPremiumSingle(player)
	return pull(player, true, 1)
end

--- Tirage x10 sur le Premium Banner. Cout : 4500 Diamants.
function BannerService.PullPremiumTen(player)
	return pull(player, true, 10)
end

--- Etat actuel des compteurs de pity (utile pour l'UI : "encore X tirages avant garantie").
function BannerService.GetPityStatus(player)
	local entry = EnsurePityEntry(player)
	return {
		Base = table.clone(entry.Base),
		Premium = table.clone(entry.Premium),
	}
end

-- ============================================================
-- Sauvegarde
-- ============================================================

function BannerService.GetSaveSnapshot(player)
	local entry = EnsurePityEntry(player)
	return {
		Base = table.clone(entry.Base),
		Premium = table.clone(entry.Premium),
	}
end

function BannerService.LoadFromSavedData(player, savedData)
	local entry = EnsurePityEntry(player)
	if savedData then
		entry.Base = savedData.Base or entry.Base
		entry.Premium = savedData.Premium or entry.Premium
	end
end

function BannerService.ClearPlayer(player)
	PlayerPity[player.UserId] = nil
end

return BannerService