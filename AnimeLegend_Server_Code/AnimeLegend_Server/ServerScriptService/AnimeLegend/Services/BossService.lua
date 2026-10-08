local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BossData = require(ReplicatedStorage.AnimeLegend.Shared.Data.BossData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local BossService = {}

function BossService:Get(name)
    return BossData[name]
end

function BossService:GetKaguyaScaling(playerCount)
    local cfg = require(ReplicatedStorage.AnimeLegend.Shared.Config.CombatConfig).BossCoop
    if playerCount <= 4 then
        local v = cfg.KaguyaPlayerScaling[playerCount] or cfg.KaguyaPlayerScaling[1]
        return v.Damage, v.Resistance
    end
    return cfg.MaxPlayersScaling.Damage, cfg.MaxPlayersScaling.Resistance
end

function BossService:AwardMiniBossDiamonds(player, bossName)
    local boss = BossData[bossName]
    if not boss or bossName == "Kaguya" then return 0 end
    local data = PlayerDataService:Get(player)
    if not data then return 0 end
    local amount = math.random(boss.DiamondMin, boss.DiamondMax)
    data.BrilliantDiamonds += amount
    return amount
end

function BossService:AwardKaguyaDiamonds(player)
    local boss = BossData.Kaguya
    local data = PlayerDataService:Get(player)
    if not data then return 0 end
    local amount = math.random(boss.DiamondMin, boss.DiamondMax)
    data.BrilliantDiamonds += amount
    return amount
end

return BossService
