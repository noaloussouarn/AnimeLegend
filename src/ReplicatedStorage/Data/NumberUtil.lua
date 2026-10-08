--[[
	NumberUtil
	----------
	Parse et formate les grands nombres utilisés dans Anime Legend
	(zones, titres, mobs, etc.) sous la forme de suffixes lisibles :
	1K, 2.5M, 100B, 1T, 1Q, 1Qi, 1Sx, ...

	Note technique : les nombres Lua sont des doubles (IEEE754). Au-dela
	d'environ 2^53 (~9e15) la precision entiere n'est plus garantie a 100%.
	Pour ce jeu (farm/idle), c'est le compromis standard utilise par la
	plupart des jeux Roblox de ce type : suffisant pour l'affichage et
	l'equilibrage, pas destine a un calcul financier exact.
	Si un jour les nombres doivent depasser 1e300+, il faudra migrer vers
	un systeme BigNumber {mantissa, exponent} - separe de ce module.
]]

local NumberUtil = {}

-- Ordre important : du plus grand au plus petit pour le parsing,
-- du plus petit au plus grand pour le formatage (voir plus bas).
local SUFFIXES = {
	{ suffix = "Td", value = 1e42 }, -- Tredecillion
	{ suffix = "Dd", value = 1e39 }, -- Duodecillion
	{ suffix = "Ud", value = 1e36 }, -- Undecillion
	{ suffix = "Dc", value = 1e33 }, -- Decillion
	{ suffix = "No", value = 1e30 }, -- Nonillion
	{ suffix = "Oc", value = 1e27 }, -- Octillion
	{ suffix = "Sp", value = 1e24 }, -- Septillion
	{ suffix = "Sx", value = 1e21 }, -- Sextillion
	{ suffix = "Qi", value = 1e18 }, -- Quintillion
	{ suffix = "Q",  value = 1e15 }, -- Quadrillion
	{ suffix = "T",  value = 1e12 }, -- Trillion
	{ suffix = "B",  value = 1e9  }, -- Billion
	{ suffix = "M",  value = 1e6  }, -- Million
	{ suffix = "K",  value = 1e3  }, -- Millier
}

--[[
	Parse("1.5K")  -> 1500
	Parse("100T")  -> 100000000000000
	Parse("250")   -> 250
	Parse(500)     -> 500 (passe les nombres bruts tels quels)
]]
function NumberUtil.Parse(input: string | number): number
	if type(input) == "number" then
		return input
	end

	assert(type(input) == "string", "NumberUtil.Parse attend une string ou un number")

	local cleaned = input:gsub("%s+", "")

	for _, entry in ipairs(SUFFIXES) do
		local suffixLen = #entry.suffix
		if #cleaned > suffixLen and cleaned:sub(-suffixLen) == entry.suffix then
			local numberPart = cleaned:sub(1, #cleaned - suffixLen)
			local n = tonumber(numberPart)
			if n then
				return n * entry.value
			end
		end
	end

	local n = tonumber(cleaned)
	assert(n ~= nil, ("NumberUtil.Parse: valeur invalide '%s'"):format(input))
	return n
end

--[[
	Format(1500)                -> "1.5K"
	Format(100000000000000)     -> "100T"
	Format(250)                 -> "250"
	decimals (optionnel) contrôle le nombre de chiffres après la virgule (défaut 2)
]]
function NumberUtil.Format(value: number, decimals: number?): string
	decimals = decimals or 2

	if value < 1000 then
		if value == math.floor(value) then
			return tostring(math.floor(value))
		end
		return tostring(value)
	end

	for _, entry in ipairs(SUFFIXES) do
		if value >= entry.value then
			local scaled = value / entry.value
			local formatted = string.format("%." .. decimals .. "f", scaled)
			-- Retire les zeros inutiles ("1.50K" -> "1.5K", "2.00M" -> "2M")
			formatted = formatted:gsub("(%.%d-)0+$", "%1"):gsub("%.$", "")
			return formatted .. entry.suffix
		end
	end

	-- Fallback au-dela du plus grand suffixe nomme (>= 1e36) : notation scientifique
	return string.format("%." .. decimals .. "e", value)
end

-- Compare deux valeurs (acceptent number OU string avec suffixe)
function NumberUtil.Compare(a: string | number, b: string | number): number
	local av = NumberUtil.Parse(a)
	local bv = NumberUtil.Parse(b)
	if av < bv then
		return -1
	elseif av > bv then
		return 1
	end
	return 0
end

-- Utilitaire pratique : est-ce que "current" atteint le "required" ?
function NumberUtil.Meets(current: number, required: string | number): boolean
	return current >= NumberUtil.Parse(required)
end

return NumberUtil
