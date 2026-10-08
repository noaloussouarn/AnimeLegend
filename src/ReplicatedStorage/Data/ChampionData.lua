--[[
	ChampionData
	------------
	Catalogue complet des Champions (GDD section 7). Stats en FRACTION
	(0.10 = 10%), ce sont des valeurs MAX au niveau 100 - voir ChampionService
	pour la formule de progression (10% -> 100% du potentiel entre niveau 1 et 100).

	Rarity (numerique, 1-10) suit exactement la table Raretes du GDD section 7.1 :
	1 Normal, 2 Inhabituel, 3 Rare, 4 Elite, 5 Epique, 6 Legendaire, 7 Mythique,
	8 Divin, 9 Celeste, 10 Transcendant.

	IsPremium distingue le pool Base Banner (73 champions, dont 3 Divins) du pool
	Premium Banner (30 champions : 10 Divins + 10 Celestes + 10 Transcendants).
	Les deux pools ont des taux de tirage separes (voir BannerService, a construire).

	Kiba/Happy/Kabuto/Chopper : stats = nil, EXPLICITEMENT non verrouillees dans le
	GDD ("leurs chiffres definitifs ne sont pas encore verrouilles"). Le code doit
	les laisser configurables - ne pas leur assigner de stats sans confirmation.
]]

export type ChampionEntry = {
	Id: number,
	Name: string,
	Rarity: number,
	IsPremium: boolean,
	MaxStats: { Durability: number?, Force: number?, Energy: number?, Speed: number?, Agility: number?, Sword: number? },
	Passif: string,
}

local ChampionData: { [number]: ChampionEntry } = {}
local nextId = 1

local function add(name, rarity, isPremium, d, f, e, s, a, sw, passif)
	ChampionData[nextId] = {
		Id = nextId,
		Name = name,
		Rarity = rarity,
		IsPremium = isPremium,
		MaxStats = { Durability = d, Force = f, Energy = e, Speed = s, Agility = a, Sword = sw },
		Passif = passif,
	}
	nextId += 1
end

-- Base Banner - Normal (rarity 1)
add("Rock Lee", 1, false, 0.1, 0.15, 0.0, 0.15, 0.15, 0.0, "Taijutsu")
add("Usopp", 1, false, 0.05, 0.1, 0.05, 0.1, 0.15, 0.0, "Tireur d'elite")
add("Ikkaku", 1, false, 0.15, 0.15, 0.05, 0.05, 0.05, 0.15, "Kenpachi's Squad")
add("Leorio", 1, false, 0.1, 0.1, 0.1, 0.05, 0.05, 0.0, "Medecin")
add("Konohamaru", 1, false, 0.05, 0.05, 0.15, 0.1, 0.1, 0.0, "Heritier du Feu")
add("Yamcha", 1, false, 0.1, 0.15, 0.1, 0.15, 0.1, 0.0, "Roga Fufu Ken")
add("Kiba", 1, false, nil, nil, nil, nil, nil, nil, "TBD")
add("Happy", 1, false, nil, nil, nil, nil, nil, nil, "TBD")
add("Kabuto", 1, false, nil, nil, nil, nil, nil, nil, "TBD")
add("Chopper", 1, false, nil, nil, nil, nil, nil, nil, "TBD")

-- Base Banner - Inhabituel (rarity 2)
add("Krillin", 2, false, 0.2, 0.2, 0.3, 0.15, 0.2, 0.0, "Kienzan")
add("Inosuke", 2, false, 0.3, 0.3, 0.0, 0.2, 0.35, 0.0, "Sens du danger")
add("Renji", 2, false, 0.25, 0.3, 0.25, 0.15, 0.2, 0.35, "Zabimaru")
add("Gon", 2, false, 0.25, 0.35, 0.3, 0.25, 0.25, 0.0, "Jajanken")
add("Nobara", 2, false, 0.15, 0.2, 0.3, 0.15, 0.25, 0.0, "Resonance")
add("Noelle", 2, false, 0.2, 0.15, 0.35, 0.15, 0.2, 0.0, "Armure Valkyrie")
add("Temari", 2, false, 0.15, 0.2, 0.3, 0.2, 0.3, 0.0, "Kamaitachi")
add("Gray", 2, false, 0.25, 0.25, 0.35, 0.2, 0.25, 0.0, "Explosion de glace")
add("Panda", 2, false, 0.35, 0.3, 0.15, 0.1, 0.15, 0.0, "Trois Coeurs")
add("Zenitsu", 2, false, 0.15, 0.2, 0.0, 0.35, 0.35, 0.25, "Foudre Instantanee")

-- Base Banner - Rare (rarity 3)
add("Kakashi", 3, false, 0.3, 0.25, 0.45, 0.3, 0.35, 0.1, "Kamui")
add("Zoro", 3, false, 0.4, 0.45, 0.0, 0.25, 0.3, 0.5, "Santoryu")
add("Byakuya", 3, false, 0.3, 0.25, 0.45, 0.3, 0.35, 0.45, "Senbonzakura")
add("Killua", 3, false, 0.25, 0.3, 0.25, 0.5, 0.5, 0.0, "Godspeed")
add("Shinobu", 3, false, 0.2, 0.2, 0.3, 0.45, 0.45, 0.3, "Poison de glycine")
add("Asta", 3, false, 0.4, 0.45, 0.4, 0.3, 0.25, 0.35, "Anti-Magie")
add("Vegeta", 3, false, 0.45, 0.5, 0.45, 0.35, 0.3, 0.0, "Final Flash")
add("Choso", 3, false, 0.3, 0.35, 0.45, 0.25, 0.3, 0.0, "Piercing Blood")
add("Piccolo", 3, false, 0.5, 0.4, 0.4, 0.2, 0.2, 0.0, "Makanko Sappo")
add("Erza", 3, false, 0.4, 0.45, 0.15, 0.3, 0.3, 0.5, "Requip")

-- Base Banner - Elite (rarity 4)
add("Itachi", 4, false, 0.4, 0.35, 0.65, 0.4, 0.5, 0.15, "Amaterasu")
add("Orochimaru", 4, false, 0.6, 0.3, 0.6, 0.2, 0.3, 0.2, "Regeneration")
add("Ace", 4, false, 0.4, 0.45, 0.65, 0.45, 0.35, 0.0, "Entei")
add("Kenpachi", 4, false, 0.65, 0.7, 0.3, 0.3, 0.25, 0.6, "Combat Sauvage")
add("Giyu", 4, false, 0.5, 0.45, 0.4, 0.5, 0.55, 0.6, "Onzieme Forme - Eclaircissement")
add("Hisoka", 4, false, 0.35, 0.45, 0.55, 0.5, 0.6, 0.0, "Bungee Gum")
add("Yami", 4, false, 0.5, 0.45, 0.65, 0.35, 0.4, 0.5, "Dimension Slash")
add("Laxus", 4, false, 0.45, 0.5, 0.7, 0.55, 0.4, 0.0, "Dragon Lightning")
add("Todo", 4, false, 0.6, 0.6, 0.35, 0.35, 0.45, 0.0, "Boogie Woogie")
add("Sasuke", 4, false, 0.45, 0.4, 0.65, 0.5, 0.6, 0.3, "Amaterasu + Kagutsuchi")

-- Base Banner - Epique (rarity 5)
add("Naruto", 5, false, 0.7, 0.75, 0.85, 0.65, 0.7, 0.0, "Mode Chakra")
add("Ichigo", 5, false, 0.75, 0.8, 0.75, 0.7, 0.75, 0.85, "Bankai")
add("Natsu", 5, false, 0.8, 0.85, 0.8, 0.6, 0.55, 0.0, "Dragon Force")
add("Sanji", 5, false, 0.65, 0.75, 0.0, 0.9, 0.85, 0.0, "Ifrit Jambe")
add("Rengoku", 5, false, 0.7, 0.8, 0.65, 0.7, 0.65, 0.85, "Ninth Form Rengoku")
add("Chrollo", 5, false, 0.55, 0.6, 0.85, 0.7, 0.9, 0.3, "Skill Hunter")
add("Yuno", 5, false, 0.55, 0.5, 0.9, 0.85, 0.8, 0.0, "Spirit Dive")
add("Goku", 5, false, 0.85, 0.9, 0.9, 0.8, 0.75, 0.0, "Kaioken")
add("Sasuke Shippuden", 5, false, 0.65, 0.65, 0.9, 0.8, 0.9, 0.5, "Susanoo")
add("Gojo", 5, false, 0.7, 0.65, 0.9, 0.75, 0.8, 0.0, "Infini")

-- Base Banner - Legendaire (rarity 6)
add("Madara", 6, false, 1.05, 1.1, 1.15, 0.75, 0.85, 0.7, "Meteore")
add("Akainu", 6, false, 1.1, 1.05, 1.15, 0.65, 0.6, 0.0, "Maguma")
add("Aizen", 6, false, 0.9, 0.85, 1.2, 0.9, 1.0, 0.75, "Kyoka Suigetsu")
add("Igneel", 6, false, 1.2, 1.15, 1.1, 0.65, 0.55, 0.0, "Dragon Roar")
add("Yoriichi", 6, false, 0.9, 1.0, 0.7, 1.15, 1.2, 1.2, "Dance of the Fire God")
add("Meruem", 6, false, 1.2, 1.2, 0.9, 1.05, 0.95, 0.0, "Roi des Fourmis")
add("Sukuna", 6, false, 1.0, 1.05, 1.2, 0.85, 0.9, 0.0, "Sanctuaire Demonique")
add("Obito", 6, false, 0.9, 0.8, 1.1, 1.0, 1.15, 0.35, "Kamui")
add("Gogeta", 6, false, 1.15, 1.2, 1.2, 1.15, 1.1, 0.0, "Stardust Breaker")
add("Hashirama", 6, false, 1.2, 1.1, 1.15, 0.7, 0.65, 0.0, "Mokuton")

-- Base Banner - Mythique (rarity 7)
add("Whitebeard", 7, false, 1.5, 1.55, 1.45, 0.8, 0.7, 0.0, "Gura Gura no Mi")
add("Acnologia", 7, false, 1.55, 1.5, 1.55, 0.85, 0.7, 0.0, "Dragon King")
add("Muzan", 7, false, 1.45, 1.3, 1.5, 1.2, 1.3, 0.0, "Regeneration Roi Demon")
add("Adult Gon", 7, false, 1.3, 1.6, 1.5, 1.45, 1.45, 0.0, "Je vais tout donner")
add("Minato", 7, false, 1.1, 1.05, 1.4, 1.55, 1.6, 0.5, "Hiraishin")
add("Lucius", 7, false, 1.2, 1.1, 1.6, 1.0, 1.25, 0.0, "Soul Magic")
add("Broly", 7, false, 1.6, 1.6, 1.45, 1.2, 1.0, 0.0, "Rage Legendaire")
add("Zeref", 7, false, 1.25, 1.05, 1.6, 0.9, 1.0, 0.0, "Ankhseram")
add("Shanks", 7, false, 1.15, 1.4, 1.5, 1.25, 1.45, 1.0, "Haki des Rois")
add("Jotaro", 7, false, 1.1, 1.35, 1.45, 1.55, 1.6, 0.0, "ZA WARUDO")

-- Base Banner - Divin (rarity 8)
add("Kaguya", 8, false, 1.9, 1.6, 2.0, 1.2, 1.4, 0.0, "Amenominaka + Expansive Truth-Seeking Ball")
add("Gol D. Roger", 8, false, 1.6, 1.95, 1.7, 1.4, 1.5, 2.0, "Haki du Roi Supreme")
add("Yhwach", 8, false, 1.5, 1.4, 2.0, 1.55, 1.8, 1.3, "The Almighty")

-- Premium Banner - Divin (rarity 8)
add("Goku Black Rose", 8, true, 1.75, 1.8, 2.05, 1.45, 1.6, 0.0, "Lame Divine")
add("Doflamingo Eveil", 8, true, 1.65, 1.75, 1.8, 1.5, 1.7, 0.0, "Parasite")
add("Yuta Okkotsu", 8, true, 1.6, 1.5, 2.1, 1.45, 1.7, 0.5, "Rika")
add("Might Guy - 8 Portes", 8, true, 1.7, 2.1, 0.0, 2.2, 2.15, 1.0, "Huitieme Porte")
add("Ulquiorra - Segunda Etapa", 8, true, 1.75, 1.65, 2.1, 1.8, 1.95, 0.6, "Lanza del Relampago")
add("Escanor - The One", 8, true, 2.1, 2.2, 1.4, 1.25, 1.1, 0.0, "THE ONE")
add("Julius Novachrono", 8, true, 1.5, 1.2, 2.2, 1.9, 2.0, 0.0, "Time Magic")
add("Shinra Kusakabe", 8, true, 1.55, 1.7, 2.05, 2.25, 2.2, 0.0, "Adolla Burst")
add("Gilgamesh", 8, true, 1.55, 1.45, 2.2, 1.6, 1.8, 0.8, "Gate of Babylon")
add("Meliodas - Assault Mode", 8, true, 2.0, 2.05, 1.85, 1.65, 1.6, 0.7, "Full Counter")

-- Premium Banner - Celeste (rarity 9)
add("Goku - Ultra Instinct maitrise", 9, true, 2.1, 2.05, 2.4, 2.3, 2.45, 0.0, "Instinct Superieur")
add("Luffy - Gear 5", 9, true, 2.15, 2.2, 2.05, 1.95, 2.05, 0.0, "Nika")
add("Naruto - Mode Baryon", 9, true, 2.05, 2.2, 2.3, 2.35, 2.25, 0.0, "Baryon Mode")
add("Sukuna - Forme Heian", 9, true, 2.1, 2.15, 2.45, 1.9, 2.05, 0.0, "Sanctuaire (Forme Heian)")
add("Ichigo - True Bankai", 9, true, 2.15, 2.2, 2.35, 2.25, 2.3, 2.45, "Getsuga Jujisho")
add("Asta - Union avec Liebe", 9, true, 2.2, 2.25, 2.15, 2.1, 2.05, 2.0, "Anti-Magie (Union)")
add("Meliodas - Demon King", 9, true, 2.4, 2.35, 2.25, 1.9, 1.85, 1.0, "Full Counter Absolu")
add("Rimuru - Roi-Demon", 9, true, 2.2, 1.9, 2.55, 1.85, 2.1, 0.0, "Predation")
add("Sung Jin-Woo - Monarque des Ombres", 9, true, 2.25, 2.15, 2.35, 2.2, 2.4, 0.8, "Armee des Ombres")
add("Yhwach - Soul King", 9, true, 2.15, 1.95, 2.6, 2.2, 2.45, 1.5, "The Almighty (Soul King)")

-- Premium Banner - Transcendant (rarity 10)
add("Zeno", 10, true, 2.5, 2.2, 3.0, 1.5, 1.5, 0.0, "Effacement Absolu")
add("Saitama - Serious Mode", 10, true, 3.0, 3.2, 1.0, 2.2, 2.0, 0.0, "Serious Punch")
add("Rimuru - True Demon Lord", 10, true, 2.6, 2.3, 3.1, 1.9, 2.3, 0.0, "Azathoth")
add("Anos", 10, true, 2.7, 2.5, 3.2, 2.0, 2.5, 1.0, "Venuzdonoa")
add("Featherine", 10, true, 2.0, 1.5, 3.5, 1.8, 3.0, 0.0, "Rewrite")
add("Sung Jin-Woo - Monarque Supreme", 10, true, 2.7, 2.5, 2.8, 2.6, 2.9, 1.0, "Arise")
add("Goku - Mastered Ultra Instinct", 10, true, 2.6, 2.8, 3.0, 3.1, 3.2, 0.0, "Ultra Instinct Parfait")
add("Ichigo - Horn of Salvation", 10, true, 2.7, 2.85, 3.0, 2.9, 3.0, 3.2, "Getsuga Tensho Ultime")
add("Shinra - Shinrabanshoman", 10, true, 2.4, 2.6, 3.3, 3.4, 3.5, 0.0, "Manipulation de la Realite")
add("Subaru - Return by Death", 10, true, 1.0, 0.8, 1.0, 1.2, 1.3, 0.0, "Return by Death")

return ChampionData