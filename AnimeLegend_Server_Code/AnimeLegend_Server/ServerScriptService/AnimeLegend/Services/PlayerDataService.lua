local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PlayerDataService = {}
PlayerDataService.__index = PlayerDataService

local STORE = DataStoreService:GetDataStore("AnimeLegend_PlayerData_v1")

local DEFAULT = {
    Money = 0,
    BrilliantDiamonds = 0,
    Stats = {Durability=0, Force=0, Energy=0, Speed=0, Agility=0, Sword=0},
    PersonalMultiplier = 1,
    NextPersonalMultiplierCost = 100,
    ActiveTitleId = 1,
    UnlockedZones = {},
    Champions = {},
    EquippedChampionIds = {},
    Specials = {},
    SpecialSlots = {},
    Powers = {},
    PowerBindings = {},
    ActiveTransformation = nil,
    Swords = {},
    EquippedSword = nil,
    CompletedQuests = {},
    QuestProgress = {},
    BannerPity = {
        Legendaire = 0,
        Mythique = 0,
        Divin = 0,
        Celeste = 0,
        Transcendant = 0,
    },
    Fragments = {},
    Dojos = {Dojo1=true, Dojo2=false},
}

local profiles = {}

local function copyTable(t)
    local c = {}
    for k,v in pairs(t) do
        c[k] = type(v) == "table" and copyTable(v) or v
    end
    return c
end

function PlayerDataService:Load(player)
    local key = "p_" .. player.UserId
    local data
    local ok, result = pcall(function()
        return STORE:GetAsync(key)
    end)
    if ok and type(result) == "table" then
        data = result
    else
        data = copyTable(DEFAULT)
    end
    profiles[player] = data
    return data
end

function PlayerDataService:Get(player)
    return profiles[player]
end

function PlayerDataService:Set(player, data)
    profiles[player] = data
end

function PlayerDataService:Save(player)
    local data = profiles[player]
    if not data then return false end
    local key = "p_" .. player.UserId
    local ok = pcall(function()
        STORE:SetAsync(key, data)
    end)
    return ok
end

function PlayerDataService:Remove(player)
    profiles[player] = nil
end

Players.PlayerRemoving:Connect(function(player)
    PlayerDataService:Save(player)
    PlayerDataService:Remove(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerDataService:Save(player)
    end
end)

return PlayerDataService
