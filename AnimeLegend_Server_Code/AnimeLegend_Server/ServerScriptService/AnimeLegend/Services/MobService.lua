local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobData = require(ReplicatedStorage.AnimeLegend.Shared.Data.MobData)
local PlayerDataService = require(script.Parent.PlayerDataService)
local MoneyService = require(script.Parent.MoneyService)

local MobService = {}

function MobService:GetMob(mobId)
    return MobData[mobId]
end

function MobService:RewardKill(player, mobId)
    local mob = MobData[mobId]
    if not mob then return false end
    local data = PlayerDataService:Get(player)
    if not data then return false end

    MoneyService:AwardMobMoney(player, mobId)
    data.ChampionXP = (data.ChampionXP or 0) + mob.ChampionXP

    if math.random() <= mob.DiamondChance / 100 then
        data.BrilliantDiamonds += 1
    end

    return true
end

return MobService
