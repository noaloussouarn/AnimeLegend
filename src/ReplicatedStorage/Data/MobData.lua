--[[
	MobData
	-------
	30 archetypes de mobs, reutilises tels quels dans les zones
	Durabilite/Force/Energie correspondantes (ex: mob 15 = D15 = F15 = E15).
	Chaque zone place 10 copies identiques du mob de son palier.

	XP Champion = 50 * numero du mob (deja calcule ci-dessous).
]]

local NumberUtil = require(script.Parent.NumberUtil)

export type MobEntry = {
	Id: number,
	Name: string,
	Anime: string,
	PV: number,
	Degats: number,
	BaseMoney: number,
	DiamondChance: number, -- en pourcentage, ex: 0.5 = 0.5%
	ChampionXP: number,
}

local MobData: { [number]: MobEntry } = {
	[1]  = { Id = 1,  Name = "Bandit de Konoha",          Anime = "Naruto",       PV = NumberUtil.Parse("100"),   Degats = NumberUtil.Parse("10"),   BaseMoney = 100,  DiamondChance = 0.5,  ChampionXP = 50 },
	[2]  = { Id = 2,  Name = "Hollow Errant",              Anime = "Bleach",       PV = NumberUtil.Parse("500"),   Degats = NumberUtil.Parse("25"),   BaseMoney = 200,  DiamondChance = 0.7,  ChampionXP = 100 },
	[3]  = { Id = 3,  Name = "Bandit des Mers",            Anime = "One Piece",    PV = NumberUtil.Parse("1K"),    Degats = NumberUtil.Parse("50"),   BaseMoney = 300,  DiamondChance = 0.9,  ChampionXP = 150 },
	[4]  = { Id = 4,  Name = "Soldat de Fiore",            Anime = "Fairy Tail",   PV = NumberUtil.Parse("2.5K"),  Degats = NumberUtil.Parse("100"),  BaseMoney = 400,  DiamondChance = 1.1,  ChampionXP = 200 },
	[5]  = { Id = 5,  Name = "Soldat de Frieza",           Anime = "Dragon Ball",  PV = NumberUtil.Parse("5K"),    Degats = NumberUtil.Parse("250"),  BaseMoney = 500,  DiamondChance = 1.3,  ChampionXP = 250 },
	[6]  = { Id = 6,  Name = "Loup de la Foret",           Anime = "Naruto",       PV = NumberUtil.Parse("10K"),   Degats = NumberUtil.Parse("500"),  BaseMoney = 600,  DiamondChance = 1.5,  ChampionXP = 300 },
	[7]  = { Id = 7,  Name = "Hollow Masque",               Anime = "Bleach",       PV = NumberUtil.Parse("25K"),   Degats = NumberUtil.Parse("1K"),   BaseMoney = 700,  DiamondChance = 1.7,  ChampionXP = 350 },
	[8]  = { Id = 8,  Name = "Pirate de Baratie",          Anime = "One Piece",    PV = NumberUtil.Parse("50K"),   Degats = NumberUtil.Parse("2.5K"), BaseMoney = 800,  DiamondChance = 1.9,  ChampionXP = 400 },
	[9]  = { Id = 9,  Name = "Mage Noir",                  Anime = "Fairy Tail",   PV = NumberUtil.Parse("100K"),  Degats = NumberUtil.Parse("5K"),   BaseMoney = 900,  DiamondChance = 2.1,  ChampionXP = 450 },
	[10] = { Id = 10, Name = "Soldat de la Red Ribbon",    Anime = "Dragon Ball",  PV = NumberUtil.Parse("250K"),  Degats = NumberUtil.Parse("10K"),  BaseMoney = 1000, DiamondChance = 2.5,  ChampionXP = 500 },
	[11] = { Id = 11, Name = "Ninja d'Orochimaru",         Anime = "Naruto",       PV = NumberUtil.Parse("500K"),  Degats = NumberUtil.Parse("25K"),  BaseMoney = 1100, DiamondChance = 3.0,  ChampionXP = 550 },
	[12] = { Id = 12, Name = "Pirate de Grand Line",       Anime = "One Piece",    PV = NumberUtil.Parse("1M"),    Degats = NumberUtil.Parse("50K"),  BaseMoney = 1200, DiamondChance = 3.5,  ChampionXP = 600 },
	[13] = { Id = 13, Name = "Shinigami Renegat",          Anime = "Bleach",       PV = NumberUtil.Parse("2.5M"),  Degats = NumberUtil.Parse("100K"), BaseMoney = 1300, DiamondChance = 4.0,  ChampionXP = 650 },
	[14] = { Id = 14, Name = "Mage de Grimoire",           Anime = "Fairy Tail",   PV = NumberUtil.Parse("5M"),    Degats = NumberUtil.Parse("250K"), BaseMoney = 1400, DiamondChance = 4.5,  ChampionXP = 700 },
	[15] = { Id = 15, Name = "Guerrier Saibaman",          Anime = "Dragon Ball",  PV = NumberUtil.Parse("10M"),   Degats = NumberUtil.Parse("500K"), BaseMoney = 1500, DiamondChance = 5.0,  ChampionXP = 750 },
	[16] = { Id = 16, Name = "Ninja d'Ame",                Anime = "Naruto",       PV = NumberUtil.Parse("25M"),   Degats = NumberUtil.Parse("1M"),   BaseMoney = 1600, DiamondChance = 6.0,  ChampionXP = 800 },
	[17] = { Id = 17, Name = "Arrancar Inferieur",         Anime = "Bleach",       PV = NumberUtil.Parse("50M"),   Degats = NumberUtil.Parse("2.5M"), BaseMoney = 1700, DiamondChance = 7.0,  ChampionXP = 850 },
	[18] = { Id = 18, Name = "Homme-Poisson Guerrier",     Anime = "One Piece",    PV = NumberUtil.Parse("100M"),  Degats = NumberUtil.Parse("5M"),   BaseMoney = 1800, DiamondChance = 8.0,  ChampionXP = 900 },
	[19] = { Id = 19, Name = "Dragon de Fiore",            Anime = "Fairy Tail",   PV = NumberUtil.Parse("250M"),  Degats = NumberUtil.Parse("10M"),  BaseMoney = 1900, DiamondChance = 9.0,  ChampionXP = 950 },
	[20] = { Id = 20, Name = "Soldat de Frieza Elite",     Anime = "Dragon Ball",  PV = NumberUtil.Parse("500M"),  Degats = NumberUtil.Parse("25M"),  BaseMoney = 2000, DiamondChance = 10.0, ChampionXP = 1000 },
	[21] = { Id = 21, Name = "Ninja de la Pluie",          Anime = "Naruto",       PV = NumberUtil.Parse("1B"),    Degats = NumberUtil.Parse("50M"),  BaseMoney = 2100, DiamondChance = 11.0, ChampionXP = 1050 },
	[22] = { Id = 22, Name = "Arrancar Guerrier",          Anime = "Bleach",       PV = NumberUtil.Parse("2.5B"),  Degats = NumberUtil.Parse("100M"), BaseMoney = 2200, DiamondChance = 12.0, ChampionXP = 1100 },
	[23] = { Id = 23, Name = "Pirate du Nouveau Monde",    Anime = "One Piece",    PV = NumberUtil.Parse("5B"),    Degats = NumberUtil.Parse("250M"), BaseMoney = 2300, DiamondChance = 13.0, ChampionXP = 1150 },
	[24] = { Id = 24, Name = "Bete Magique",               Anime = "Fairy Tail",   PV = NumberUtil.Parse("10B"),   Degats = NumberUtil.Parse("500M"), BaseMoney = 2400, DiamondChance = 14.0, ChampionXP = 1200 },
	[25] = { Id = 25, Name = "Soldat de la Force Ginyu",   Anime = "Dragon Ball",  PV = NumberUtil.Parse("25B"),   Degats = NumberUtil.Parse("1B"),   BaseMoney = 2500, DiamondChance = 15.0, ChampionXP = 1250 },
	[26] = { Id = 26, Name = "Ninja ANBU Renegat",         Anime = "Naruto",       PV = NumberUtil.Parse("50B"),   Degats = NumberUtil.Parse("2.5B"), BaseMoney = 2600, DiamondChance = 16.0, ChampionXP = 1300 },
	[27] = { Id = 27, Name = "Fraccion Arrancar",          Anime = "Bleach",       PV = NumberUtil.Parse("100B"),  Degats = NumberUtil.Parse("5B"),   BaseMoney = 2700, DiamondChance = 17.0, ChampionXP = 1350 },
	[28] = { Id = 28, Name = "Pirate de Wano",             Anime = "One Piece",    PV = NumberUtil.Parse("250B"),  Degats = NumberUtil.Parse("10B"),  BaseMoney = 2800, DiamondChance = 18.0, ChampionXP = 1400 },
	[29] = { Id = 29, Name = "Demon Magique",              Anime = "Fairy Tail",   PV = NumberUtil.Parse("500B"),  Degats = NumberUtil.Parse("25B"),  BaseMoney = 2900, DiamondChance = 19.0, ChampionXP = 1450 },
	[30] = { Id = 30, Name = "Soldat de Frieza Ultime",    Anime = "Dragon Ball",  PV = NumberUtil.Parse("1T"),    Degats = NumberUtil.Parse("50B"),  BaseMoney = 3000, DiamondChance = 20.0, ChampionXP = 1500 },
}

return MobData
