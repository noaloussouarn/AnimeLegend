--[[
	BannerData
	----------
	Taux de tirage, pity et valeurs de Fragments par doublon (GDD section 8 +
	addendum section 1). Rarity utilise les memes IDs 1-10 que ChampionData.

	IMPORTANT : les FRAGMENT_VALUE_PER_DUPLICATE sont les valeurs VERROUILLEES
	du GDD ("Valeurs verrouillees proposees"). Ce sont les fragments RECUS quand
	on tire un doublon - pas le cout pour evoluer un Champion d'une etoile (ce
	cout-la n'est pas verrouille dans le GDD, voir le commentaire dans
	ChampionService.FRAGMENT_COST_PER_RARITY).
]]

local BannerData = {}

-- Probabilites globales par rarete, Base Banner (rarity 1-8). Somme = 100.
BannerData.BASE_RARITY_WEIGHTS = {
	[1] = 45,   -- Normal
	[2] = 25,   -- Inhabituel
	[3] = 15,   -- Rare
	[4] = 8,    -- Elite
	[5] = 4,    -- Epique
	[6] = 2,    -- Legendaire
	[7] = 0.8,  -- Mythique
	[8] = 0.2,  -- Divin
}

-- Probabilites globales par rarete, Premium Banner (rarity 8-10 uniquement). Somme = 100.
BannerData.PREMIUM_RARITY_WEIGHTS = {
	[8] = 85,  -- Divin
	[9] = 14,  -- Celeste
	[10] = 1,  -- Transcendant
}

-- Pity : { rarity minimum garantie = nombre de tirages avant garantie }.
-- Compteurs INDEPENDANTS (un tirage rate sur un palier ne reset pas les autres).
BannerData.BASE_PITY = {
	{ rarity = 6, count = 50 },   -- Legendaire+
	{ rarity = 7, count = 150 },  -- Mythique+
	{ rarity = 8, count = 500 },  -- Divin+
}

BannerData.PREMIUM_PITY = {
	{ rarity = 9, count = 1500 },  -- Celeste+
	{ rarity = 10, count = 5000 }, -- Transcendant
}

-- Fragments recus en cas de doublon, par rarete (GDD section 8, verrouille).
BannerData.FRAGMENT_VALUE_PER_DUPLICATE = {
	[1] = 5, [2] = 10, [3] = 25, [4] = 50, [5] = 100,
	[6] = 250, [7] = 500, [8] = 1000, [9] = 2500, [10] = 5000,
}

-- Couts en Diamants Brillants (addendum v3, valeurs corrigees/autoritaires).
BannerData.COSTS = {
	Base = { Single = 10, Ten = 100 },      -- pas de reduction sur le x10 (verrouille)
	Premium = { Single = 500, Ten = 4500 }, -- reduction de 10% sur le x10 (verrouille)
}

return BannerData