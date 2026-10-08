--[[
	TitleData
	---------
	Les titres sont lineaires et obligatoires dans l'ordre (pas de skip).
	Chaque titre demande exactement 3 conditions de stats.
	Le multiplicateur d'argent double a chaque titre.

	Stat utilise les memes cles que StatsService : "Durability", "Force",
	"Energy", "Speed", "Agility", "Sword".
]]

local NumberUtil = require(script.Parent.NumberUtil)

export type TitleCondition = {
	Stat: string,
	Amount: number,
}

export type TitleEntry = {
	Id: number,
	Name: string,
	Conditions: { TitleCondition },
	MoneyMultiplier: number,
	MoneyPerMinute: number,
}

local function C(stat: string, amount: string): TitleCondition
	return { Stat = stat, Amount = NumberUtil.Parse(amount) }
end

local TitleData: { [number]: TitleEntry } = {
	[1]  = { Id = 1,  Name = "Combattant",          Conditions = { C("Durability", "1K"),   C("Force", "1K"),    C("Agility", "500") },  MoneyMultiplier = 1,      MoneyPerMinute = 100 },
	[2]  = { Id = 2,  Name = "Shinobi",              Conditions = { C("Durability", "10K"),  C("Energy", "10K"),  C("Agility", "5K") },   MoneyMultiplier = 2,      MoneyPerMinute = 200 },
	[3]  = { Id = 3,  Name = "Épéiste",               Conditions = { C("Force", "100K"),      C("Sword", "100K"),  C("Agility", "50K") },  MoneyMultiplier = 4,      MoneyPerMinute = 400 },
	[4]  = { Id = 4,  Name = "Pirate",               Conditions = { C("Durability", "1M"),   C("Force", "1M"),    C("Sword", "1M") },     MoneyMultiplier = 8,      MoneyPerMinute = 800 },
	[5]  = { Id = 5,  Name = "Shinigami",            Conditions = { C("Force", "10M"),       C("Energy", "10M"),  C("Sword", "10M") },    MoneyMultiplier = 16,     MoneyPerMinute = 1600 },
	[6]  = { Id = 6,  Name = "Saiyan",               Conditions = { C("Durability", "100M"), C("Force", "100M"),  C("Energy", "100M") },  MoneyMultiplier = 32,     MoneyPerMinute = 3200 },
	[7]  = { Id = 7,  Name = "Mage",                 Conditions = { C("Energy", "1B"),       C("Speed", "100M"),  C("Agility", "100M") }, MoneyMultiplier = 64,     MoneyPerMinute = 6400 },
	[8]  = { Id = 8,  Name = "Hunter",               Conditions = { C("Force", "10B"),       C("Energy", "10B"),  C("Agility", "1B") },   MoneyMultiplier = 128,    MoneyPerMinute = 12800 },
	[9]  = { Id = 9,  Name = "Sorcier",              Conditions = { C("Energy", "100B"),     C("Speed", "10B"),   C("Agility", "10B") },  MoneyMultiplier = 256,    MoneyPerMinute = 25600 },
	[10] = { Id = 10, Name = "Maître Épéiste",        Conditions = { C("Durability", "1T"),   C("Sword", "1T"),    C("Speed", "100B") },   MoneyMultiplier = 512,    MoneyPerMinute = 51200 },
	[11] = { Id = 11, Name = "Chasseur de Démons",    Conditions = { C("Durability", "10T"),  C("Force", "10T"),   C("Agility", "1T") },   MoneyMultiplier = 1024,   MoneyPerMinute = 102400 },
	[12] = { Id = 12, Name = "Exorciste",            Conditions = { C("Force", "100T"),      C("Energy", "100T"), C("Agility", "10T") },  MoneyMultiplier = 2048,   MoneyPerMinute = 204800 },
	[13] = { Id = 13, Name = "Dragon Slayer",        Conditions = { C("Durability", "1Q"),   C("Force", "1Q"),    C("Energy", "1Q") },    MoneyMultiplier = 4096,   MoneyPerMinute = 409600 },
	[14] = { Id = 14, Name = "Maître du Nen",         Conditions = { C("Force", "10Q"),       C("Energy", "10Q"),  C("Agility", "1Q") },   MoneyMultiplier = 8192,   MoneyPerMinute = 819200 },
	[15] = { Id = 15, Name = "Fléau Maudit",          Conditions = { C("Durability", "100Q"), C("Energy", "100Q"), C("Speed", "10Q") },    MoneyMultiplier = 16384,  MoneyPerMinute = NumberUtil.Parse("1.638M") },
	[16] = { Id = 16, Name = "Démon Supérieur",       Conditions = { C("Durability", "1Qi"),  C("Force", "1Qi"),   C("Energy", "1Qi") },   MoneyMultiplier = 32768,  MoneyPerMinute = NumberUtil.Parse("3.277M") },
	[17] = { Id = 17, Name = "Maître Spirituel",      Conditions = { C("Energy", "10Qi"),     C("Speed", "1Qi"),   C("Agility", "1Qi") },  MoneyMultiplier = 65536,  MoneyPerMinute = NumberUtil.Parse("6.554M") },
	[18] = { Id = 18, Name = "Seigneur de Guerre",    Conditions = { C("Durability", "100Qi"),C("Force", "100Qi"), C("Sword", "100Qi") },  MoneyMultiplier = 131072, MoneyPerMinute = NumberUtil.Parse("13.107M") },
	[19] = { Id = 19, Name = "Dieu Guerrier",        Conditions = { C("Durability", "1Sx"),  C("Force", "1Sx"),   C("Energy", "1Sx") },   MoneyMultiplier = 262144, MoneyPerMinute = NumberUtil.Parse("26.214M") },
	[20] = { Id = 20, Name = "Légende Vivante",       Conditions = { C("Durability", "10Sx"), C("Force", "10Sx"),  C("Sword", "10Sx") },   MoneyMultiplier = 524288, MoneyPerMinute = NumberUtil.Parse("52.428M") },
}

return TitleData
