local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChampionData = require(ReplicatedStorage.AnimeLegend.Shared.Data.ChampionData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local ChampionService = {}

function ChampionService:AddXP(player, amount)
    local data = PlayerDataService:Get(player)
    if not data then return false end
    data.ChampionXP = (data.ChampionXP or 0) + math.max(0, amount or 0)
    return true
end

function ChampionService:GetLevelFromXP(xp)
    -- Configurable approximation targeting ~10M total XP at level 100.
    xp = math.max(0, xp or 0)
    local level = math.floor(math.sqrt(xp / 1000) * 31) + 1
    return math.clamp(level, 1, 100)
end

function ChampionService:GetScaledBonus(level, maxBonus)
    level = math.clamp(level or 1, 1, 100)
    local progress = 0.10 + 0.90 * ((level - 1) / 99)
    return maxBonus * progress
end

function ChampionService:GetDefinition(id)
    return ChampionData[id]
end

return ChampionService
