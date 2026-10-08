local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TitleData = require(ReplicatedStorage.AnimeLegend.Shared.Data.TitleData)
local PlayerDataService = require(script.Parent.PlayerDataService)
local StatsService = require(script.Parent.StatsService)

local TitleService = {}

function TitleService:MeetsRequirements(player, titleId)
    local title = TitleData[titleId]
    if not title then return false end
    local data = PlayerDataService:Get(player)
    if not data then return false end
    if titleId ~= 1 and (data.ActiveTitleId or 0) < titleId - 1 then
        return false
    end
    for stat, required in pairs(title.Requirements) do
        if StatsService:GetStat(player, stat) < required then
            return false
        end
    end
    return true
end

function TitleService:TryUnlock(player, titleId)
    local data = PlayerDataService:Get(player)
    if not data or not self:MeetsRequirements(player, titleId) then
        return false
    end
    data.ActiveTitleId = math.max(data.ActiveTitleId or 1, titleId)
    return true
end

function TitleService:GetMoneyMultiplier(player)
    local data = PlayerDataService:Get(player)
    local id = data and data.ActiveTitleId or 1
    return TitleData[id] and TitleData[id].MoneyMultiplier or 1
end

return TitleService
