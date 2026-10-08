--[[
	SwordData
	---------
	Liste des 30 premieres epees de World 1, dans l'ordre d'obtention
	via les quetes de dojo (voir GDD section 3.4/3.5).

	Une epee ne possede QUE : nom, univers/reference et multiplicateur Sword.
	Elle n'a pas d'attaques propres (celles-ci vivent dans les Specials ou les Pouvoirs).

	IMPORTANT sur Multiplier : le GDD donne l'ORDRE exact des 30 epees mais ne
	verrouille pas de valeurs de multiplicateur precises pour chacune (contrairement
	aux zones qui ont une table Palier verrouillee). C'est explicitement une
	recompense de quete a equilibrer. La progression ci-dessous est un PREMIER JET
	(doublement progressif, cout de configuration ici) - a retoucher librement,
	un seul endroit a changer.
]]

local NumberUtil = require(script.Parent.NumberUtil)

export type SwordEntry = {
	Id: number,
	Name: string,
	Anime: string,
	Multiplier: number,
}

-- Progression placeholder : x1 -> x1.5 -> x2 -> x3 -> x4 -> x6 -> x8 ... (doublement tous les ~3 epees)
-- Genere ici plutot qu'ecrit a la main pour rester facile a rebalancer.
local function placeholderMultiplier(index: number): number
	local tier = math.floor((index - 1) / 3)
	local withinTier = (index - 1) % 3
	local base = 2 ^ tier
	local steps = { 1, 1.5, 2 }
	return base * steps[withinTier + 1]
end

local SWORDS: { { Name: string, Anime: string } } = {
	{ Name = "Katana d'Entrainement", Anime = "Original" },
	{ Name = "Sakabato", Anime = "Rurouni Kenshin" },
	{ Name = "Wado Ichimonji", Anime = "One Piece" },
	{ Name = "Sandai Kitetsu", Anime = "One Piece" },
	{ Name = "Enma", Anime = "One Piece" },
	{ Name = "Shusui", Anime = "One Piece" },
	{ Name = "Nidai Kitetsu", Anime = "One Piece" },
	{ Name = "Zangetsu", Anime = "Bleach" },
	{ Name = "Tensa Zangetsu", Anime = "Bleach" },
	{ Name = "Ryujin Jakka", Anime = "Bleach" },
	{ Name = "Senbonzakura", Anime = "Bleach" },
	{ Name = "Nozarashi", Anime = "Bleach" },
	{ Name = "Hyorinmaru", Anime = "Bleach" },
	{ Name = "Zabimaru", Anime = "Bleach" },
	{ Name = "Nichirin de Yoriichi", Anime = "Demon Slayer" },
	{ Name = "Nichirin de Tanjiro", Anime = "Demon Slayer" },
	{ Name = "Nichirin de Rengoku", Anime = "Demon Slayer" },
	{ Name = "Nichirin de Zenitsu", Anime = "Demon Slayer" },
	{ Name = "Nichirin de Giyu", Anime = "Demon Slayer" },
	{ Name = "Rita", Anime = "Seven Deadly Sins" },
	{ Name = "Lostvayne", Anime = "Seven Deadly Sins" },
	{ Name = "Chastiefol", Anime = "Seven Deadly Sins" },
	{ Name = "Demon-Dweller Sword", Anime = "Black Clover" },
	{ Name = "Demon-Slayer Sword", Anime = "Black Clover" },
	{ Name = "Demon-Destroyer Sword", Anime = "Black Clover" },
	{ Name = "Kusanagi", Anime = "Naruto" },
	{ Name = "Kubikiribocho", Anime = "Naruto" },
	{ Name = "Samehada", Anime = "Naruto" },
	{ Name = "Sword of Totsuka", Anime = "Naruto" },
	{ Name = "Executioner's Blade", Anime = "Fairy Tail" },
}

local SwordData: { [number]: SwordEntry } = {}

for index, sword in ipairs(SWORDS) do
	SwordData[index] = {
		Id = index,
		Name = sword.Name,
		Anime = sword.Anime,
		Multiplier = NumberUtil.Parse(tostring(placeholderMultiplier(index))),
	}
end

return SwordData