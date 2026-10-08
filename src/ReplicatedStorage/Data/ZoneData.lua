--[[
	ZoneData
	--------
	100 zones de farm : 30 Durabilite (D) + 30 Force (F) + 30 Energie (E)
	+ 5 Vitesse (V) + 5 Agilite (A). Sword est hors de ces 100 zones (voir SwordData).

	RequiredStat (Dura/Force/Energie uniquement) est une extrapolation directe de la
	progression decrite dans le GDD (1K->10K->...->1T puis pas plus espaces).
	Ce n'est PAS une table verrouillee dans le document source : a retoucher lors de
	l'equilibrage. Vitesse/Agilite n'ont pas de requis documente -> laisse a nil.

	BossGate : None / "Imu" / "Frieza" / "Yhwach" (uniquement D30/F30/E30).
]]

local NumberUtil = require(script.Parent.NumberUtil)

export type ZoneEntry = {
	ZoneId: string,
	Name: string,
	Anime: string,
	StatType: string,
	Multiplier: number,
	RequiredStat: number?,
	MobId: number?,
	BossGate: string?,
	TeleportAnchor: string,
}

local ZoneData: { [string]: ZoneEntry } = {}

-- Durability (30 zones)
ZoneData["D01"] = { ZoneId = "D01", Name = "Village de Konoha", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("4"), RequiredStat = NumberUtil.Parse("1K"), MobId = 1, TeleportAnchor = "D01" }
ZoneData["D02"] = { ZoneId = "D02", Name = "Seireitei", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("12"), RequiredStat = NumberUtil.Parse("10K"), MobId = 2, TeleportAnchor = "D02" }
ZoneData["D03"] = { ZoneId = "D03", Name = "Ile de Jaya", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("35"), RequiredStat = NumberUtil.Parse("100K"), MobId = 3, TeleportAnchor = "D03" }
ZoneData["D04"] = { ZoneId = "D04", Name = "Magnolia", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("100"), RequiredStat = NumberUtil.Parse("1M"), MobId = 4, TeleportAnchor = "D04" }
ZoneData["D05"] = { ZoneId = "D05", Name = "West City", Anime = "Dragon Ball", StatType = "Durability", Multiplier = NumberUtil.Parse("300"), RequiredStat = NumberUtil.Parse("10M"), MobId = 5, TeleportAnchor = "D05" }
ZoneData["D06"] = { ZoneId = "D06", Name = "Village de Suna", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("900"), RequiredStat = NumberUtil.Parse("100M"), MobId = 6, TeleportAnchor = "D06" }
ZoneData["D07"] = { ZoneId = "D07", Name = "Boutique Urahara", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("2.5K"), RequiredStat = NumberUtil.Parse("1B"), MobId = 7, TeleportAnchor = "D07" }
ZoneData["D08"] = { ZoneId = "D08", Name = "Marineford", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("7.5K"), RequiredStat = NumberUtil.Parse("10B"), MobId = 8, TeleportAnchor = "D08" }
ZoneData["D09"] = { ZoneId = "D09", Name = "Arene de Crocus", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("22K"), RequiredStat = NumberUtil.Parse("100B"), MobId = 9, TeleportAnchor = "D09" }
ZoneData["D10"] = { ZoneId = "D10", Name = "Planete Namek", Anime = "Dragon Ball", StatType = "Durability", Multiplier = NumberUtil.Parse("65K"), RequiredStat = NumberUtil.Parse("1T"), MobId = 10, TeleportAnchor = "D10" }
ZoneData["D11"] = { ZoneId = "D11", Name = "Pays des Vagues", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("200K"), RequiredStat = NumberUtil.Parse("100T"), MobId = 11, TeleportAnchor = "D11" }
ZoneData["D12"] = { ZoneId = "D12", Name = "Enies Lobby", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("600K"), RequiredStat = NumberUtil.Parse("1Q"), MobId = 12, TeleportAnchor = "D12" }
ZoneData["D13"] = { ZoneId = "D13", Name = "Las Noches", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("1.8M"), RequiredStat = NumberUtil.Parse("100Q"), MobId = 13, TeleportAnchor = "D13" }
ZoneData["D14"] = { ZoneId = "D14", Name = "Ile de Tenro", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("5M"), RequiredStat = NumberUtil.Parse("1Qi"), MobId = 14, TeleportAnchor = "D14" }
ZoneData["D15"] = { ZoneId = "D15", Name = "Cell Games Arena", Anime = "Dragon Ball", StatType = "Durability", Multiplier = NumberUtil.Parse("15M"), RequiredStat = NumberUtil.Parse("100Qi"), MobId = 15, TeleportAnchor = "D15" }
ZoneData["D16"] = { ZoneId = "D16", Name = "Village d\'Ame", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("45M"), RequiredStat = NumberUtil.Parse("1Sx"), MobId = 16, TeleportAnchor = "D16" }
ZoneData["D17"] = { ZoneId = "D17", Name = "Quartier Kuchiki", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("135M"), RequiredStat = NumberUtil.Parse("100Sx"), MobId = 17, TeleportAnchor = "D17" }
ZoneData["D18"] = { ZoneId = "D18", Name = "Pays de Wano", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("400M"), RequiredStat = NumberUtil.Parse("1Sp"), MobId = 18, TeleportAnchor = "D18" }
ZoneData["D19"] = { ZoneId = "D19", Name = "Mont Hakobe", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("1.2B"), RequiredStat = NumberUtil.Parse("100Sp"), MobId = 19, TeleportAnchor = "D19" }
ZoneData["D20"] = { ZoneId = "D20", Name = "Capsule Corporation", Anime = "Dragon Ball", StatType = "Durability", Multiplier = NumberUtil.Parse("3.5B"), RequiredStat = NumberUtil.Parse("1Oc"), MobId = 20, TeleportAnchor = "D20" }
ZoneData["D21"] = { ZoneId = "D21", Name = "Foret de la Mort", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("10B"), RequiredStat = NumberUtil.Parse("100Oc"), MobId = 21, TeleportAnchor = "D21" }
ZoneData["D22"] = { ZoneId = "D22", Name = "Archipel Sabaody", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("30B"), RequiredStat = NumberUtil.Parse("1No"), MobId = 22, TeleportAnchor = "D22" }
ZoneData["D23"] = { ZoneId = "D23", Name = "Foret des Menos", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("90B"), RequiredStat = NumberUtil.Parse("100No"), MobId = 23, TeleportAnchor = "D23" }
ZoneData["D24"] = { ZoneId = "D24", Name = "Antre d\'Acnologia", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("270B"), RequiredStat = NumberUtil.Parse("1Dc"), MobId = 24, TeleportAnchor = "D24" }
ZoneData["D25"] = { ZoneId = "D25", Name = "Palais du Roi", Anime = "Dragon Ball", StatType = "Durability", Multiplier = NumberUtil.Parse("800B"), RequiredStat = NumberUtil.Parse("100Dc"), MobId = 25, TeleportAnchor = "D25" }
ZoneData["D26"] = { ZoneId = "D26", Name = "Vallee de la Fin", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("2.5T"), RequiredStat = NumberUtil.Parse("1Ud"), MobId = 26, TeleportAnchor = "D26" }
ZoneData["D27"] = { ZoneId = "D27", Name = "Wahrwelt", Anime = "Bleach", StatType = "Durability", Multiplier = NumberUtil.Parse("8T"), RequiredStat = NumberUtil.Parse("100Ud"), MobId = 27, TeleportAnchor = "D27" }
ZoneData["D28"] = { ZoneId = "D28", Name = "Onigashima", Anime = "One Piece", StatType = "Durability", Multiplier = NumberUtil.Parse("25T"), RequiredStat = NumberUtil.Parse("1Dd"), MobId = 28, TeleportAnchor = "D28" }
ZoneData["D29"] = { ZoneId = "D29", Name = "Royaume de Fiore", Anime = "Fairy Tail", StatType = "Durability", Multiplier = NumberUtil.Parse("80T"), RequiredStat = NumberUtil.Parse("100Dd"), MobId = 29, TeleportAnchor = "D29" }
ZoneData["D30"] = { ZoneId = "D30", Name = "Dimension de Kaguya", Anime = "Naruto", StatType = "Durability", Multiplier = NumberUtil.Parse("250T"), RequiredStat = NumberUtil.Parse("1Td"), MobId = 30, BossGate = "Imu", TeleportAnchor = "D30" }

-- Force (30 zones)
ZoneData["F01"] = { ZoneId = "F01", Name = "Village de Konoha", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("4"), RequiredStat = NumberUtil.Parse("1K"), MobId = 1, TeleportAnchor = "F01" }
ZoneData["F02"] = { ZoneId = "F02", Name = "Ville de Karakura", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("12"), RequiredStat = NumberUtil.Parse("10K"), MobId = 2, TeleportAnchor = "F02" }
ZoneData["F03"] = { ZoneId = "F03", Name = "Alabasta", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("35"), RequiredStat = NumberUtil.Parse("100K"), MobId = 3, TeleportAnchor = "F03" }
ZoneData["F04"] = { ZoneId = "F04", Name = "Royaume de Fiore", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("100"), RequiredStat = NumberUtil.Parse("1M"), MobId = 4, TeleportAnchor = "F04" }
ZoneData["F05"] = { ZoneId = "F05", Name = "Maison de Goku", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("300"), RequiredStat = NumberUtil.Parse("10M"), MobId = 5, TeleportAnchor = "F05" }
ZoneData["F06"] = { ZoneId = "F06", Name = "Repaire d\'Orochimaru", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("900"), RequiredStat = NumberUtil.Parse("100M"), MobId = 6, TeleportAnchor = "F06" }
ZoneData["F07"] = { ZoneId = "F07", Name = "Academie Shin\'o", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("2.5K"), RequiredStat = NumberUtil.Parse("1B"), MobId = 7, TeleportAnchor = "F07" }
ZoneData["F08"] = { ZoneId = "F08", Name = "Water 7", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("7.5K"), RequiredStat = NumberUtil.Parse("10B"), MobId = 8, TeleportAnchor = "F08" }
ZoneData["F09"] = { ZoneId = "F09", Name = "Mont Hakobe", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("22K"), RequiredStat = NumberUtil.Parse("100B"), MobId = 9, TeleportAnchor = "F09" }
ZoneData["F10"] = { ZoneId = "F10", Name = "Central City", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("65K"), RequiredStat = NumberUtil.Parse("1T"), MobId = 10, TeleportAnchor = "F10" }
ZoneData["F11"] = { ZoneId = "F11", Name = "Quartier Uchiha", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("200K"), RequiredStat = NumberUtil.Parse("100T"), MobId = 11, TeleportAnchor = "F11" }
ZoneData["F12"] = { ZoneId = "F12", Name = "Dressrosa", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("600K"), RequiredStat = NumberUtil.Parse("1Q"), MobId = 12, TeleportAnchor = "F12" }
ZoneData["F13"] = { ZoneId = "F13", Name = "Colline du Sokyoku", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("1.8M"), RequiredStat = NumberUtil.Parse("100Q"), MobId = 13, TeleportAnchor = "F13" }
ZoneData["F14"] = { ZoneId = "F14", Name = "Grand Tournoi de la Magie", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("5M"), RequiredStat = NumberUtil.Parse("1Qi"), MobId = 14, TeleportAnchor = "F14" }
ZoneData["F15"] = { ZoneId = "F15", Name = "Planete de Kaio", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("15M"), RequiredStat = NumberUtil.Parse("100Qi"), MobId = 15, TeleportAnchor = "F15" }
ZoneData["F16"] = { ZoneId = "F16", Name = "Konoha - Quartier ANBU", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("45M"), RequiredStat = NumberUtil.Parse("1Sx"), MobId = 16, TeleportAnchor = "F16" }
ZoneData["F17"] = { ZoneId = "F17", Name = "Las Noches", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("135M"), RequiredStat = NumberUtil.Parse("100Sx"), MobId = 17, TeleportAnchor = "F17" }
ZoneData["F18"] = { ZoneId = "F18", Name = "Capitale des Fleurs", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("400M"), RequiredStat = NumberUtil.Parse("1Sp"), MobId = 18, TeleportAnchor = "F18" }
ZoneData["F19"] = { ZoneId = "F19", Name = "Empire d\'Arbaless", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("1.2B"), RequiredStat = NumberUtil.Parse("100Sp"), MobId = 19, TeleportAnchor = "F19" }
ZoneData["F20"] = { ZoneId = "F20", Name = "Enfer de Frieza", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("3.5B"), RequiredStat = NumberUtil.Parse("1Oc"), MobId = 20, TeleportAnchor = "F20" }
ZoneData["F21"] = { ZoneId = "F21", Name = "Village d\'Ame - Tour de Pain", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("10B"), RequiredStat = NumberUtil.Parse("100Oc"), MobId = 21, TeleportAnchor = "F21" }
ZoneData["F22"] = { ZoneId = "F22", Name = "Enies Lobby", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("30B"), RequiredStat = NumberUtil.Parse("1No"), MobId = 22, TeleportAnchor = "F22" }
ZoneData["F23"] = { ZoneId = "F23", Name = "Seireitei - Division des Capitaines", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("90B"), RequiredStat = NumberUtil.Parse("100No"), MobId = 23, TeleportAnchor = "F23" }
ZoneData["F24"] = { ZoneId = "F24", Name = "Sanctuaire d\'Acnologia", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("270B"), RequiredStat = NumberUtil.Parse("1Dc"), MobId = 24, TeleportAnchor = "F24" }
ZoneData["F25"] = { ZoneId = "F25", Name = "Tournoi du Pouvoir", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("800B"), RequiredStat = NumberUtil.Parse("100Dc"), MobId = 25, TeleportAnchor = "F25" }
ZoneData["F26"] = { ZoneId = "F26", Name = "Vallee de la Fin", Anime = "Naruto", StatType = "Force", Multiplier = NumberUtil.Parse("2.5T"), RequiredStat = NumberUtil.Parse("1Ud"), MobId = 26, TeleportAnchor = "F26" }
ZoneData["F27"] = { ZoneId = "F27", Name = "Palais du Roi des Ames", Anime = "Bleach", StatType = "Force", Multiplier = NumberUtil.Parse("8T"), RequiredStat = NumberUtil.Parse("100Ud"), MobId = 27, TeleportAnchor = "F27" }
ZoneData["F28"] = { ZoneId = "F28", Name = "Onigashima - Toit", Anime = "One Piece", StatType = "Force", Multiplier = NumberUtil.Parse("25T"), RequiredStat = NumberUtil.Parse("1Dd"), MobId = 28, TeleportAnchor = "F28" }
ZoneData["F29"] = { ZoneId = "F29", Name = "Royaume des Dragons", Anime = "Fairy Tail", StatType = "Force", Multiplier = NumberUtil.Parse("80T"), RequiredStat = NumberUtil.Parse("100Dd"), MobId = 29, TeleportAnchor = "F29" }
ZoneData["F30"] = { ZoneId = "F30", Name = "Palais de Frieza", Anime = "Dragon Ball", StatType = "Force", Multiplier = NumberUtil.Parse("250T"), RequiredStat = NumberUtil.Parse("1Td"), MobId = 30, BossGate = "Frieza", TeleportAnchor = "F30" }

-- Energy (30 zones)
ZoneData["E01"] = { ZoneId = "E01", Name = "Foret de la Mort", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("4"), RequiredStat = NumberUtil.Parse("1K"), MobId = 1, TeleportAnchor = "E01" }
ZoneData["E02"] = { ZoneId = "E02", Name = "Boutique Urahara", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("12"), RequiredStat = NumberUtil.Parse("10K"), MobId = 2, TeleportAnchor = "E02" }
ZoneData["E03"] = { ZoneId = "E03", Name = "Grand Line", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("35"), RequiredStat = NumberUtil.Parse("100K"), MobId = 3, TeleportAnchor = "E03" }
ZoneData["E04"] = { ZoneId = "E04", Name = "Guilde Fairy Tail", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("100"), RequiredStat = NumberUtil.Parse("1M"), MobId = 4, TeleportAnchor = "E04" }
ZoneData["E05"] = { ZoneId = "E05", Name = "Capsule Corporation", Anime = "Dragon Ball", StatType = "Energy", Multiplier = NumberUtil.Parse("300"), RequiredStat = NumberUtil.Parse("10M"), MobId = 5, TeleportAnchor = "E05" }
ZoneData["E06"] = { ZoneId = "E06", Name = "Village Cache de la Pluie", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("900"), RequiredStat = NumberUtil.Parse("100M"), MobId = 6, TeleportAnchor = "E06" }
ZoneData["E07"] = { ZoneId = "E07", Name = "Quartier des Capitaines", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("2.5K"), RequiredStat = NumberUtil.Parse("1B"), MobId = 7, TeleportAnchor = "E07" }
ZoneData["E08"] = { ZoneId = "E08", Name = "Skypiea", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("7.5K"), RequiredStat = NumberUtil.Parse("10B"), MobId = 8, TeleportAnchor = "E08" }
ZoneData["E09"] = { ZoneId = "E09", Name = "Ile de Tenro", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("22K"), RequiredStat = NumberUtil.Parse("100B"), MobId = 9, TeleportAnchor = "E09" }
ZoneData["E10"] = { ZoneId = "E10", Name = "Planete Namek", Anime = "Dragon Ball", StatType = "Energy", Multiplier = NumberUtil.Parse("65K"), RequiredStat = NumberUtil.Parse("1T"), MobId = 10, TeleportAnchor = "E10" }
ZoneData["E11"] = { ZoneId = "E11", Name = "Arene des Examens Chunin", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("200K"), RequiredStat = NumberUtil.Parse("100T"), MobId = 11, TeleportAnchor = "E11" }
ZoneData["E12"] = { ZoneId = "E12", Name = "Hueco Mundo", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("600K"), RequiredStat = NumberUtil.Parse("1Q"), MobId = 12, TeleportAnchor = "E12" }
ZoneData["E13"] = { ZoneId = "E13", Name = "Ile des Hommes-Poissons", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("1.8M"), RequiredStat = NumberUtil.Parse("100Q"), MobId = 13, TeleportAnchor = "E13" }
ZoneData["E14"] = { ZoneId = "E14", Name = "Cite de Crocus", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("5M"), RequiredStat = NumberUtil.Parse("1Qi"), MobId = 14, TeleportAnchor = "E14" }
ZoneData["E15"] = { ZoneId = "E15", Name = "Tournoi des Arts Martiaux", Anime = "Dragon Ball", StatType = "Energy", Multiplier = NumberUtil.Parse("15M"), RequiredStat = NumberUtil.Parse("100Qi"), MobId = 15, TeleportAnchor = "E15" }
ZoneData["E16"] = { ZoneId = "E16", Name = "Village de Suna", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("45M"), RequiredStat = NumberUtil.Parse("1Sx"), MobId = 16, TeleportAnchor = "E16" }
ZoneData["E17"] = { ZoneId = "E17", Name = "Dangai", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("135M"), RequiredStat = NumberUtil.Parse("100Sx"), MobId = 17, TeleportAnchor = "E17" }
ZoneData["E18"] = { ZoneId = "E18", Name = "Punk Hazard", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("400M"), RequiredStat = NumberUtil.Parse("1Sp"), MobId = 18, TeleportAnchor = "E18" }
ZoneData["E19"] = { ZoneId = "E19", Name = "Foret de Magnolia", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("1.2B"), RequiredStat = NumberUtil.Parse("100Sp"), MobId = 19, TeleportAnchor = "E19" }
ZoneData["E20"] = { ZoneId = "E20", Name = "Monde des Kaio Shin", Anime = "Dragon Ball", StatType = "Energy", Multiplier = NumberUtil.Parse("3.5B"), RequiredStat = NumberUtil.Parse("1Oc"), MobId = 20, TeleportAnchor = "E20" }
ZoneData["E21"] = { ZoneId = "E21", Name = "Konoha - Mont Hokage", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("10B"), RequiredStat = NumberUtil.Parse("100Oc"), MobId = 21, TeleportAnchor = "E21" }
ZoneData["E22"] = { ZoneId = "E22", Name = "Wahrwelt", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("30B"), RequiredStat = NumberUtil.Parse("1No"), MobId = 22, TeleportAnchor = "E22" }
ZoneData["E23"] = { ZoneId = "E23", Name = "Wano - Chateau d\'Orochi", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("90B"), RequiredStat = NumberUtil.Parse("100No"), MobId = 23, TeleportAnchor = "E23" }
ZoneData["E24"] = { ZoneId = "E24", Name = "Empire d\'Alvarez", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("270B"), RequiredStat = NumberUtil.Parse("1Dc"), MobId = 24, TeleportAnchor = "E24" }
ZoneData["E25"] = { ZoneId = "E25", Name = "Monde des Morts", Anime = "Dragon Ball", StatType = "Energy", Multiplier = NumberUtil.Parse("800B"), RequiredStat = NumberUtil.Parse("100Dc"), MobId = 25, TeleportAnchor = "E25" }
ZoneData["E26"] = { ZoneId = "E26", Name = "Vallee de la Fin", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("2.5T"), RequiredStat = NumberUtil.Parse("1Ud"), MobId = 26, TeleportAnchor = "E26" }
ZoneData["E27"] = { ZoneId = "E27", Name = "Palais du Roi des Ames", Anime = "Bleach", StatType = "Energy", Multiplier = NumberUtil.Parse("8T"), RequiredStat = NumberUtil.Parse("100Ud"), MobId = 27, TeleportAnchor = "E27" }
ZoneData["E28"] = { ZoneId = "E28", Name = "Laugh Tale", Anime = "One Piece", StatType = "Energy", Multiplier = NumberUtil.Parse("25T"), RequiredStat = NumberUtil.Parse("1Dd"), MobId = 28, TeleportAnchor = "E28" }
ZoneData["E29"] = { ZoneId = "E29", Name = "Sanctuaire du Dragon", Anime = "Fairy Tail", StatType = "Energy", Multiplier = NumberUtil.Parse("80T"), RequiredStat = NumberUtil.Parse("100Dd"), MobId = 29, TeleportAnchor = "E29" }
ZoneData["E30"] = { ZoneId = "E30", Name = "Dimension Centrale de Kaguya", Anime = "Naruto", StatType = "Energy", Multiplier = NumberUtil.Parse("250T"), RequiredStat = NumberUtil.Parse("1Td"), MobId = 30, BossGate = "Yhwach", TeleportAnchor = "E30" }

-- Speed (5 zones) - pas de requis/mob verrouilles dans le GDD, a definir en equilibrage
ZoneData["V01"] = { ZoneId = "V01", Name = "Village de Kumo", Anime = "Naruto", StatType = "Speed", Multiplier = NumberUtil.Parse("300"), RequiredStat = nil, MobId = nil, TeleportAnchor = "V01" }
ZoneData["V02"] = { ZoneId = "V02", Name = "Ville de Karakura", Anime = "Bleach", StatType = "Speed", Multiplier = NumberUtil.Parse("7.5K"), RequiredStat = nil, MobId = nil, TeleportAnchor = "V02" }
ZoneData["V03"] = { ZoneId = "V03", Name = "Heavenly Arena", Anime = "Hunter x Hunter", StatType = "Speed", Multiplier = NumberUtil.Parse("400M"), RequiredStat = nil, MobId = nil, TeleportAnchor = "V03" }
ZoneData["V04"] = { ZoneId = "V04", Name = "Zou - Terre des Minks", Anime = "One Piece", StatType = "Speed", Multiplier = NumberUtil.Parse("3.5B"), RequiredStat = nil, MobId = nil, TeleportAnchor = "V04" }
ZoneData["V05"] = { ZoneId = "V05", Name = "Dimension de la Vitesse", Anime = "Dragon Ball", StatType = "Speed", Multiplier = NumberUtil.Parse("250T"), RequiredStat = nil, MobId = nil, TeleportAnchor = "V05" }

-- Agility (5 zones) - pas de requis/mob verrouilles dans le GDD, a definir en equilibrage
ZoneData["A01"] = { ZoneId = "A01", Name = "Foret des Singes", Anime = "Hunter x Hunter", StatType = "Agility", Multiplier = NumberUtil.Parse("900"), RequiredStat = nil, MobId = nil, TeleportAnchor = "A01" }
ZoneData["A02"] = { ZoneId = "A02", Name = "Shibuya", Anime = "Jujutsu Kaisen", StatType = "Agility", Multiplier = NumberUtil.Parse("65K"), RequiredStat = nil, MobId = nil, TeleportAnchor = "A02" }
ZoneData["A03"] = { ZoneId = "A03", Name = "Desert de Suna", Anime = "Naruto", StatType = "Agility", Multiplier = NumberUtil.Parse("1.8M"), RequiredStat = nil, MobId = nil, TeleportAnchor = "A03" }
ZoneData["A04"] = { ZoneId = "A04", Name = "Morioh", Anime = "JoJo", StatType = "Agility", Multiplier = NumberUtil.Parse("10B"), RequiredStat = nil, MobId = nil, TeleportAnchor = "A04" }
ZoneData["A05"] = { ZoneId = "A05", Name = "Royaume de l\'Infini", Anime = "Jujutsu Kaisen", StatType = "Agility", Multiplier = NumberUtil.Parse("250T"), RequiredStat = nil, MobId = nil, TeleportAnchor = "A05" }

return ZoneData