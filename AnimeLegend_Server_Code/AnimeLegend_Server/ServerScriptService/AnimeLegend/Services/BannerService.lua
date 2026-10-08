local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.AnimeLegend.Shared.Config.EconomyConfig)
local PlayerDataService = require(script.Parent.PlayerDataService)

local BannerService = {}

local NormalRates = {
    Normal=0.45, Inhabituel=0.25, Rare=0.15, Elite=0.08,
    Epique=0.04, Legendaire=0.02, Mythique=0.008, Divin=0.002,
}

local PremiumRates = {
    Divin=0.85, Celeste=0.14, Transcendant=0.01,
}

local Pity = {
    Legendaire=50,
    Mythique=150,
    Divin=500,
    Celeste=1500,
    Transcendant=5000,
}

function BannerService:GetRates(kind)
    return kind == "Premium" and PremiumRates or NormalRates
end

function BannerService:GetCost(kind, count)
    if kind == "Premium" then
        return count == 10 and EconomyConfig.Banner.PremiumTen or EconomyConfig.Banner.PremiumSingle
    end
    return count == 10 and EconomyConfig.Banner.NormalTen or EconomyConfig.Banner.NormalSingle
end

function BannerService:GetPityThreshold(kind, rarity)
    if kind == "Premium" then
        if rarity == "Celeste" then return 50 end
        if rarity == "Transcendant" then return 100 end
    end
    return Pity[rarity]
end

function BannerService:CanSpend(player, kind, count)
    local data = PlayerDataService:Get(player)
    if not data then return false end
    return data.BrilliantDiamonds >= self:GetCost(kind, count)
end

return BannerService
