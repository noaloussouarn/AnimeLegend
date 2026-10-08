local Players = game:GetService("Players")

local root = script.Parent.Parent
local servicesFolder = root.Services

local services = {
    PlayerData = require(servicesFolder.PlayerDataService),
    Money = require(servicesFolder.MoneyService),
    Stats = require(servicesFolder.StatsService),
    Zones = require(servicesFolder.ZoneService),
    Combat = require(servicesFolder.CombatService),
    Mob = require(servicesFolder.MobService),
    Quest = require(servicesFolder.QuestService),
    Title = require(servicesFolder.TitleService),
    Champion = require(servicesFolder.ChampionService),
    Banner = require(servicesFolder.BannerService),
    Special = require(servicesFolder.SpecialService),
    Power = require(servicesFolder.PowerService),
    Sword = require(servicesFolder.SwordService),
    Boss = require(servicesFolder.BossService),
    Leaderboard = require(servicesFolder.LeaderboardService),
}

_G.AnimeLegendServices = services

Players.PlayerAdded:Connect(function(player)
    services.PlayerData:Load(player)
    -- Future: initialize leaderstats, attributes, remotes, combat controller, etc.
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        services.PlayerData:Load(player)
    end)
end

print("[AnimeLegend] Server foundation loaded.")
