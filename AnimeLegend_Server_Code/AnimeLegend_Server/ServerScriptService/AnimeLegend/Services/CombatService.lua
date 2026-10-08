local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage.AnimeLegend.Shared.Config.CombatConfig)
local StatsService = require(script.Parent.StatsService)

local CombatService = {}

function CombatService:CalculateResistanceFromPercent(percent)
    return math.clamp(percent or 0, 0, CombatConfig.Resistance.MaxPercent)
end

function CombatService:ApplyResistance(rawDamage, resistancePercent)
    local r = self:CalculateResistanceFromPercent(resistancePercent)
    return math.max(0, rawDamage * (1 - r))
end

function CombatService:CalculatePlayerDamage(player, rawDamage)
    local resistance = StatsService:GetResistancePercent(player)
    return self:ApplyResistance(rawDamage, 0), resistance
end

function CombatService:ApplyDamageToHumanoid(targetHumanoid, rawDamage)
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        return 0
    end
    local damage = math.max(0, rawDamage)
    targetHumanoid:TakeDamage(damage)
    return damage
end

function CombatService:GetBasicAttackDamage()
    return CombatConfig.BasicAttackDamage
end

return CombatService
