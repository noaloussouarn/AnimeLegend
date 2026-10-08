--[[
	DataCheck (temporaire)
	-----------------------
	Script de verification : confirme que les data tables se chargent
	correctement une fois synchronisees via Rojo. Tu pourras le supprimer
	une fois que les vrais services (StatsService, EconomyService, etc.)
	seront en place.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = ReplicatedStorage:WaitForChild("Data")

local NumberUtil = require(Data:WaitForChild("NumberUtil"))
local MobData = require(Data:WaitForChild("MobData"))
local TitleData = require(Data:WaitForChild("TitleData"))
local ZoneData = require(Data:WaitForChild("ZoneData"))

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Services")
local StatsService = require(Services:WaitForChild("StatsService"))

local zoneCount = 0
for _ in pairs(ZoneData) do
	zoneCount += 1
end

print("=== Anime Legend - Data Check ===")
print(("Mobs charges : %d"):format(#MobData))
print(("Titres charges : %d"):format(#TitleData))
print(("Zones chargees : %d"):format(zoneCount))
print(("Exemple mob 15 : %s (%s PV)"):format(MobData[15].Name, NumberUtil.Format(MobData[15].PV)))
print(("Exemple titre 10 : %s (mult argent x%d)"):format(TitleData[10].Name, TitleData[10].MoneyMultiplier))
print(("Exemple zone D30 : %s (requis %s %s, boss %s)"):format(
	ZoneData["D30"].Name,
	NumberUtil.Format(ZoneData["D30"].RequiredStat),
	ZoneData["D30"].StatType,
	tostring(ZoneData["D30"].BossGate)
))

-- Test StatsService avec un faux joueur (pas besoin d'un vrai Player, juste un UserId)
local fakePlayer = { UserId = -1 }

print("--- Test StatsService ---")
print(("Multiplicateur personnel initial : x%d"):format(StatsService.GetPersonalMultiplier(fakePlayer)))
print(("Cout du prochain niveau : %d Y"):format(StatsService.GetNextPersonalMultiplierCost(fakePlayer)))

StatsService.ApplyFarmGain(fakePlayer, "D15", 1)
print(("Apres 1 gain de farm en D15 : Durability = %s"):format(NumberUtil.Format(StatsService.GetStat(fakePlayer, "Durability"))))

StatsService.ApplyPersonalMultiplierUpgrade(fakePlayer)
print(("Multiplicateur personnel apres 1 upgrade : x%d"):format(StatsService.GetPersonalMultiplier(fakePlayer)))

print(("Peut farmer D30 ? %s"):format(tostring(StatsService.MeetsZoneRequirement(fakePlayer, "D30"))))
print(("HP combat estime : %.1f"):format(StatsService.GetCombatMaxHP(fakePlayer)))

print("=== Si tu vois ce message sans erreur, StatsService fonctionne ===")
