local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestData = require(ReplicatedStorage.AnimeLegend.Shared.Data.QuestData)
local PlayerDataService = require(script.Parent.PlayerDataService)
local MoneyService = require(script.Parent.MoneyService)
local StatsService = require(script.Parent.StatsService)

local QuestService = {}

local questIndex = {}
for _, q in ipairs(QuestData.World1 or {}) do
    questIndex[q.Id] = q
end

function QuestService:GetQuest(id)
    return questIndex[id]
end

function QuestService:TrackKill(player, mobId)
    local data = PlayerDataService:Get(player)
    if not data then return end
    data.QuestProgress.Kill = data.QuestProgress.Kill or {}
    data.QuestProgress.Kill[mobId] = (data.QuestProgress.Kill[mobId] or 0) + 1
end

function QuestService:IsComplete(player, questId)
    local q = questIndex[questId]
    local data = PlayerDataService:Get(player)
    if not q or not data then return false end

    if data.CompletedQuests[questId] then
        return false
    end

    if q.Type == "KillMob" then
        local current = (((data.QuestProgress or {}).Kill or {})[q.MobId]) or 0
        return current >= q.Amount
    elseif q.Type == "FarmStat" then
        return StatsService:GetStat(player, q.Stat) >= q.Amount
    end

    return false
end

function QuestService:Claim(player, questId)
    local q = questIndex[questId]
    local data = PlayerDataService:Get(player)
    if not q or not data or not self:IsComplete(player, questId) then
        return false, "NotComplete"
    end

    data.CompletedQuests[questId] = true
    MoneyService:AwardQuestMoney(player, q.RewardMoneyBase)

    if q.RewardPower then
        data.Powers[q.RewardPower] = true
    end

    return true
end

return QuestService
