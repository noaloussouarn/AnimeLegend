return {
    -- Quests are server validated.
    -- Mob quest example: {Type="KillMob", MobId=1, Amount=50, RewardMoney=1000, RewardPower="Katon_BouleDeFeu"}
    -- Farm quest example: {Type="FarmStat", Stat="Energy", Amount=25000, RewardMoney=5000, RewardPower="Kamehameha"}
    World1 = {
        {
            Id="Q_Katon_01", Type="KillMob", MobId=1, Amount=50,
            RewardMoneyBase=1000, RewardPower="Katon_BouleDeFeu",
        },
        {
            Id="Q_Rasengan_01", Type="KillMob", MobId=1, Amount=150,
            RewardMoneyBase=2500, RewardPower="Rasengan",
        },
        {
            Id="Q_Kamehameha_01", Type="FarmStat", Stat="Energy", Amount=25000,
            RewardMoneyBase=5000, RewardPower="Kamehameha",
        },
        {
            Id="Q_MilleSlash_01", Type="KillMob", MobId=2, Amount=250,
            RewardMoneyBase=7500, RewardPower="Mille_Slash",
        },
        {
            Id="Q_Soru_01", Type="FarmStat", Stat="Speed", Amount=10000,
            RewardMoneyBase=10000, RewardPower="Soru",
        },
        {
            Id="Q_FireDragonRoar_01", Type="FarmStat", Stat="Energy", Amount=100000,
            RewardMoneyBase=15000, RewardPower="Fire_Dragon_Roar",
        },
        -- Extend with the remaining locked World 1 Power quests from the GDD.
    }
}
