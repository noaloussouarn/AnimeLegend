local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage.AnimeLegend.Shared.Config.CombatConfig)
local StatType = require(ReplicatedStorage.AnimeLegend.Shared.Enums.StatType)
local PlayerDataService = require(script.Parent.PlayerDataService)

local StatsService = {}

function StatsService:GetStat(player, stat)
    local data = PlayerDataService:Get(player)
    return data and data.Stats[stat] or 0
end

function StatsService:AddStat(player, stat, amount)
    local data = PlayerDataService:Get(player)
    if not data or type(amount) ~= "number" or amount < 0 then
        return false
    end
    if data.Stats[stat] == nil then
        return false
    end
    data.Stats[stat] += amount
    return true
end

function StatsService:GetCombatMaxHP(player)
    local dura = self:GetStat(player, StatType.Durability)
    return math.max(100, 100 + dura * CombatConfig.HPPerDurability)
end

function StatsService:GetResistancePercent(player)
    local dura = self:GetStat(player, StatType.Durability)
    local raw = dura / CombatConfig.Resistance.DurabilityPerPercent / 100
    return math.clamp(raw, CombatConfig.Resistance.BasePercent, CombatConfig.Resistance.MaxPercent)
end

return StatsService
