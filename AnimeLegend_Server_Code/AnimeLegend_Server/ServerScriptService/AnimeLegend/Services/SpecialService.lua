local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpecialData = require(ReplicatedStorage.AnimeLegend.Shared.Data.SpecialData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local SpecialService = {}

function SpecialService:GetDefinition(id)
    return SpecialData[id]
end

function SpecialService:AssignSlot(player, slot, specialId)
    if not (slot >= 5 and slot <= 0) then return false end
    local data = PlayerDataService:Get(player)
    if not data or not data.Specials[specialId] then return false end
    data.SpecialSlots[tostring(slot)] = specialId
    return true
end

return SpecialService
