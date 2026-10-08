return {
    Imu = {
        Id="Imu", HP=10000, Durability=100, Force=35, Energy=40, Speed=25, Agility=30,
        GateZone="D30", DiamondMin=30, DiamondMax=60,
        Powers = {
            {Id="Imu_NetherArrow", Name="Flèche du Néant", DropChance=0.10},
            {Id="Imu_NetherTerror", Name="Terreur du Néant", DropChance=0.05},
            {Id="Imu_Sovereign", Name="Souverain du Monde", DropChance=0.01},
        },
    },

    Frieza = {
        Id="Frieza", HP=7500, Durability=50, Force=100, Energy=60, Speed=40, Agility=35,
        GateZone="F30", DiamondMin=30, DiamondMax=60,
        Powers = {
            {Id="Frieza_DeathBeam", Name="Death Beam", DropChance=0.10},
            {Id="Frieza_DeathBall", Name="Death Ball", DropChance=0.05},
            {Id="Frieza_Golden", Name="Golden Frieza", DropChance=0.01},
        },
    },

    Yhwach = {
        Id="Yhwach", HP=5000, Durability=40, Force=45, Energy=100, Speed=55, Agility=70,
        GateZone="E30", DiamondMin=30, DiamondMax=60,
        Powers = {
            {Id="Yhwach_SanktAltar", Name="Sankt Altar", DropChance=0.10},
            {Id="Yhwach_Almighty", Name="Almighty", DropChance=0.05},
            {Id="Yhwach_SoulKing", Name="Soul King", DropChance=0.01},
        },
    },

    Kaguya = {
        Id="Kaguya", HP=25000, Durability=150, Force=100, Energy=200, Speed=80, Agility=120,
        Phases = {1,2,3},
        DiamondMin=100, DiamondMax=200,
        Powers = {
            {Id="Kaguya_Amenominaka", Name="Amenominaka", DropChance=0.08},
            {Id="Kaguya_AshBones", Name="Ash Bones", DropChance=0.06},
            {Id="Kaguya_TruthOrb", Name="Boule de Vérité Expansive", DropChance=0.03},
            {Id="Kaguya_Yomotsu", Name="Yomotsu Hirasaka", DropChance=0.05},
            {Id="Kaguya_Transform", Name="Transformation Kaguya", DropChance=0.005},
        },
    },
}
