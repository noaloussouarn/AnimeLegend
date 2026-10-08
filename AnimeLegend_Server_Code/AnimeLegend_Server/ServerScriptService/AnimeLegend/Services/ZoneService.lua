local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZoneData = require(ReplicatedStorage.AnimeLegend.Shared.Data.ZoneData)
local PlayerDataService = require(script.Parent.PlayerDataService)
local StatsService = require(script.Parent.StatsService)

local ZoneService = {}

function ZoneService:CanFarm(player, zoneId)
    local zone = ZoneData[zoneId]
    if not zone then return false, "UnknownZone" end
    local current = StatsService:GetStat(player, zone.StatType)
    if current < zone.RequiredStat then
        return false, "Requirement"
    end
    return true
end

function ZoneService:Unlock(player, zoneId)
    local data = PlayerDataService:Get(player)
    if not data or not ZoneData[zoneId] then return false end
    data.UnlockedZones[zoneId] = true
    return true
end

function ZoneService:IsUnlocked(player, zoneId)
    local data = PlayerDataService:Get(player)
    return data and data.UnlockedZones[zoneId] == true
end

function ZoneService:GetFarmMultiplier(zoneId)
    return ZoneData[zoneId] and ZoneData[zoneId].Multiplier or 1
end

return ZoneService
