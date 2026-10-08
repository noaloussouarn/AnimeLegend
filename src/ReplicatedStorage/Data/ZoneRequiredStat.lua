--[[
	ZoneRequiredStat
	-----------------
	Le GDD (section 3) decrit la courbe de seuils d'entree ainsi, sans donner
	les 30 valeurs exactes (marque explicitement "implementation/equilibrage") :

		Debut du monde (paliers rapproches, x10 a chaque palier) :
		1K -> 10K -> 100K -> 1M -> 10M -> 100M -> 1B -> 10B -> 100B -> 1T

		Milieu/fin du monde (paliers plus espaces, alterne x100 puis x10) :
		1T -> 100T -> 1Q -> 100Q -> 1Qi -> ...

	Ce module implemente cette courbe comme une formule generique plutot que
	des valeurs figees, pour rester facilement rebalancable (un seul endroit
	a modifier) et extensible a World 2+.

	IMPORTANT : ce sont des valeurs de premier jet. A ajuster en playtest.
]]

local ZoneRequiredStat = {}

function ZoneRequiredStat.ForPalier(palier: number): number
	assert(type(palier) == "number" and palier >= 1, "palier doit etre un nombre >= 1")

	if palier <= 10 then
		-- 1K, 10K, 100K, ... 1T
		return 10 ^ (palier + 2)
	end

	-- Au-dela du palier 10, on alterne x100 puis x10 en partant de 1T (palier 10)
	local value = 10 ^ 12
	local nextStepIsX100 = true
	for _ = 11, palier do
		if nextStepIsX100 then
			value = value * 100
		else
			value = value * 10
		end
		nextStepIsX100 = not nextStepIsX100
	end

	return value
end

return ZoneRequiredStat
