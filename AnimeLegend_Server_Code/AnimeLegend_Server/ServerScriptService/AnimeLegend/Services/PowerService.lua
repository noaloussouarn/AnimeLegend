local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerData = require(ReplicatedStorage.AnimeLegend.Shared.Data.PowerData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local PowerService = {}

local forbidden = {Z=true, X=true, C=true, V=true, ["1"]=true, ["2"]=true, ["3"]=true, ["4"]=true}

function PowerService:Assign(player, key, powerId)
    local data = PlayerDataService:Get(player)
    if not data or not data.Powers[powerId] or forbidden[key] then
        return false
    end
    data.PowerBindings[key] = powerId
    return true
end

function PowerService:GetDefinition(id)
    return PowerData[id]
end

return PowerService
