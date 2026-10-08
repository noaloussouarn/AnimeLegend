local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.AnimeLegend.Shared.Config.EconomyConfig)
local PlayerDataService = require(script.Parent.PlayerDataService)

local MoneyService = {}

function MoneyService:GetTitleMultiplier(player)
    local data = PlayerDataService:Get(player)
    if not data then return 1 end
    local titleId = data.ActiveTitleId or 1
    local factor = EconomyConfig.TitleMoney.MultiplierFactor
    return factor ^ (titleId - 1)
end

function MoneyService:AwardMobMoney(player, mobId)
    local data = PlayerDataService:Get(player)
    if not data then return 0 end
    local base = EconomyConfig.MobMoney.Base + EconomyConfig.MobMoney.Increment * (mobId - 1)
    local amount = math.floor(base * self:GetTitleMultiplier(player))
    data.Money += amount
    return amount
end

function MoneyService:AwardQuestMoney(player, baseAmount)
    local data = PlayerDataService:Get(player)
    if not data then return 0 end
    local amount = math.floor(baseAmount * self:GetTitleMultiplier(player))
    data.Money += amount
    return amount
end

function MoneyService:TryPurchasePersonalMultiplier(player)
    local data = PlayerDataService:Get(player)
    if not data then return false, "NoData" end
    local cost = data.NextPersonalMultiplierCost
    if data.Money < cost then
        return false, "InsufficientFunds"
    end
    data.Money -= cost
    data.PersonalMultiplier *= EconomyConfig.PersonalMultiplier.MultiplierFactor
    data.NextPersonalMultiplierCost *= EconomyConfig.PersonalMultiplier.CostFactor
    return true, data.PersonalMultiplier
end

return MoneyService
