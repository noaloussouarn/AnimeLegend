--[[
	EconomyService
	--------------
	Responsable de (GDD section 2.2 + architecture section 13) :
	- L'argent (Y) du joueur : ajout, depense, verification de solde
	- Les Diamants Brillants (monnaie des bannieres) : meme logique
	- Le calcul des recompenses de mobs : base du mob x multiplicateur d'argent du titre
	- Le cout du multiplicateur personnel (delegue a StatsService, mais EconomyService
	  valide/debite l'argent avant d'appliquer l'upgrade)
	- Les revenus passifs Y/minute du titre

	IMPORTANT - separation des responsabilites :
	Ce service ne connait PAS les titres eux-memes (nom, conditions, palier).
	Ca, c'est le job de TitleService (pas encore construit). Les fonctions ici
	qui ont besoin du multiplicateur/¥ par minute du titre le recoivent en
	PARAMETRE, fourni par l'appelant (futur TitleService), exactement comme
	StatsService.ApplyFarmGain recoit le bonus Champion en parametre.

	SERVEUR UNIQUEMENT. Aucune fonction ne doit etre appelable directement
	par le client (ca passera par des RemoteEvents valides plus tard, via
	Security).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")
local MobData = require(Data:WaitForChild("MobData"))

local StatsService = require(script.Parent:WaitForChild("StatsService"))

local EconomyService = {}

local PlayerEconomy = {} -- [UserId] = { Money, Diamonds }

local function EnsurePlayerEntry(player)
	local uid = player.UserId
	if not PlayerEconomy[uid] then
		PlayerEconomy[uid] = {
			Money = 0,
			Diamonds = 0,
		}
	end
	return PlayerEconomy[uid]
end

-- ============================================================
-- Argent
-- ============================================================

function EconomyService.GetMoney(player): number
	return EnsurePlayerEntry(player).Money
end

--- Ajoute de l'argent. SERVEUR UNIQUEMENT. Retourne le nouveau solde.
function EconomyService.AddMoney(player, amount: number): number
	assert(type(amount) == "number" and amount == amount, "EconomyService: amount invalide")
	local entry = EnsurePlayerEntry(player)
	entry.Money = math.max(0, entry.Money + amount)
	return entry.Money
end

--[[
	Tente de depenser de l'argent. Retourne true + nouveau solde si le joueur
	a assez d'argent, sinon false + solde inchange (rien n'est deduit).
]]
function EconomyService.SpendMoney(player, amount: number): (boolean, number)
	assert(type(amount) == "number" and amount >= 0, "EconomyService: amount invalide")
	local entry = EnsurePlayerEntry(player)
	if entry.Money < amount then
		return false, entry.Money
	end
	entry.Money -= amount
	return true, entry.Money
end

-- ============================================================
-- Diamants Brillants
-- ============================================================

function EconomyService.GetDiamonds(player): number
	return EnsurePlayerEntry(player).Diamonds
end

function EconomyService.AddDiamonds(player, amount: number): number
	assert(type(amount) == "number" and amount == amount, "EconomyService: amount invalide")
	local entry = EnsurePlayerEntry(player)
	entry.Diamonds = math.max(0, entry.Diamonds + amount)
	return entry.Diamonds
end

function EconomyService.SpendDiamonds(player, amount: number): (boolean, number)
	assert(type(amount) == "number" and amount >= 0, "EconomyService: amount invalide")
	local entry = EnsurePlayerEntry(player)
	if entry.Diamonds < amount then
		return false, entry.Diamonds
	end
	entry.Diamonds -= amount
	return true, entry.Diamonds
end

-- ============================================================
-- Recompenses de mobs (GDD section 2.2 : "Argent reel = recompense de base
-- du mob x multiplicateur d'argent du titre/classe")
-- ============================================================

--- Calcule (sans l'appliquer) la recompense en argent pour un kill de mob donne.
function EconomyService.CalculateMobMoneyReward(mobId: number, titleMoneyMultiplier: number): number
	local mob = MobData[mobId]
	assert(mob, ("EconomyService: mob inconnu id=%s"):format(tostring(mobId)))
	return mob.BaseMoney * titleMoneyMultiplier
end

--[[
	Calcule ET applique la recompense en argent d'un kill de mob.
	titleMoneyMultiplier : fourni par TitleService (multiplicateur du titre actif).
	Retourne le montant ajoute.
]]
function EconomyService.GrantMobMoneyReward(player, mobId: number, titleMoneyMultiplier: number): number
	local reward = EconomyService.CalculateMobMoneyReward(mobId, titleMoneyMultiplier)
	EconomyService.AddMoney(player, reward)
	return reward
end

-- ============================================================
-- Revenus passifs Y/minute (GDD section 6 : chaque titre donne du ¥/minute)
-- ============================================================

--[[
	A appeler periodiquement (ex: toutes les 5-10 secondes depuis une boucle
	serveur) avec le ¥/minute du titre actif et le temps ecoule depuis le
	dernier appel. Ajoute la portion proportionnelle d'argent.
]]
function EconomyService.GrantPassiveIncomeTick(player, moneyPerMinute: number, elapsedSeconds: number): number
	local amount = moneyPerMinute * (elapsedSeconds / 60)
	return EconomyService.AddMoney(player, amount)
end

-- ============================================================
-- Multiplicateur personnel (GDD section 2.1) - delegue a StatsService
-- ============================================================

--[[
	Tente d'acheter le prochain niveau de multiplicateur personnel :
	verifie le cout via StatsService, debite l'argent si suffisant, puis
	applique l'upgrade. Retourne (true, nouveauMultiplicateur) ou (false, coutRequis).
]]
function EconomyService.TryPurchasePersonalMultiplierUpgrade(player): (boolean, number)
	local cost = StatsService.GetNextPersonalMultiplierCost(player)
	local success = EconomyService.SpendMoney(player, cost)

	if not success then
		return false, cost
	end

	local newMultiplier = StatsService.ApplyPersonalMultiplierUpgrade(player)
	return true, newMultiplier
end

-- ============================================================
-- Sauvegarde
-- ============================================================

function EconomyService.GetSaveSnapshot(player)
	local entry = EnsurePlayerEntry(player)
	return {
		Money = entry.Money,
		Diamonds = entry.Diamonds,
	}
end

function EconomyService.LoadFromSavedData(player, savedData)
	local entry = EnsurePlayerEntry(player)
	entry.Money = (savedData and savedData.Money) or 0
	entry.Diamonds = (savedData and savedData.Diamonds) or 0
end

function EconomyService.ClearPlayer(player)
	PlayerEconomy[player.UserId] = nil
end

return EconomyService