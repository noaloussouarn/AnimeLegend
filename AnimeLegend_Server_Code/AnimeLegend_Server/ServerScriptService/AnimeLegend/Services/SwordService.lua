local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordData = require(ReplicatedStorage.AnimeLegend.Shared.Data.SwordData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local SwordService = {}

function SwordService:GetDefinition(id)
    return SwordData[id]
end

function SwordService:Equip(player, swordId)
    local data = PlayerDataService:Get(player)
    if not data or not data.Swords[swordId] then return false end
    data.EquippedSword = swordId
    return true
end

function SwordService:GetMultiplier(player)
    local data = PlayerDataService:Get(player)
    local swordId = data and data.EquippedSword
    local def = swordId and SwordData[swordId]
    return def and def.Multiplier or 1
end

return SwordService
