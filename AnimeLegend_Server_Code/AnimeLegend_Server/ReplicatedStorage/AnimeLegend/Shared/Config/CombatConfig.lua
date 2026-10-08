return {
    BasicAttackDamage = 5,

    -- Combat HP is intentionally separate from farm numbers.
    HPPerDurability = 10,

    Resistance = {
        MaxPercent = 0.75,
        BasePercent = 0,
        DurabilityPerPercent = 100, -- configurable balance point
    },

    Status = {
        MaxStunSeconds = 10,
        DefaultSlowPercent = 0.25,
        DefaultDOTTickSeconds = 1,
        DefaultRegenTickSeconds = 1,
    },

    BossCoop = {
        KaguyaBaseResistanceMultiplier = 1.0,
        KaguyaPlayerScaling = {
            [1] = {Damage = 1.00, Resistance = 1.00},
            [2] = {Damage = 1.15, Resistance = 1.15},
            [3] = {Damage = 1.25, Resistance = 1.25},
            [4] = {Damage = 1.35, Resistance = 1.35},
        },
        MaxPlayersScaling = {Damage = 1.50, Resistance = 1.50},
    },
}
