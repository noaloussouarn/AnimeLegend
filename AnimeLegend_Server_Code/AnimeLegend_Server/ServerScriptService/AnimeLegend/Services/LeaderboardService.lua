local DataStoreService = game:GetService("DataStoreService")
local LeaderboardService = {}

local stores = {
    Durability = DataStoreService:GetOrderedDataStore("AnimeLegend_LB_Durability_v1"),
    Force = DataStoreService:GetOrderedDataStore("AnimeLegend_LB_Force_v1"),
    Energy = DataStoreService:GetOrderedDataStore("AnimeLegend_LB_Energy_v1"),
    Sword = DataStoreService:GetOrderedDataStore("AnimeLegend_LB_Sword_v1"),
}

function LeaderboardService:Update(userId, stat, value)
    local store = stores[stat]
    if not store then return false end
    return pcall(function()
        store:SetAsync(tostring(userId), value)
    end)
end

return LeaderboardService
