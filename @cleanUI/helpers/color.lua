--[[
	colors.lua
	A helper designed to make dealing with texture vertex shading and other colors

	API Functions:
	 - colorGradient
		param  | perc - a 0-1 percentage value for the gradient
		return | r,g,b in percentage values

	 - RGBToHex
		param  | r, g, b - color values, you can also pass a table to r with r,g,b fields
		return | formated hex code

	 - unitColor
		param  | unit token, such as party1, player, target ect
		return | r, g, b color values
]]--

local db = select(2, ...)
local config = db.config.API

function db.API:colorGradient(perc)
	if perc > 1 then perc = 1 end

	local segment, realperc = math.modf(perc*2)
	r1, g1, b1, r2, g2, b2 = unpack(config.colorGradient, (segment * 3) + 1)
	return r1 + (r2-r1)*realperc, g1 + (g2-g1)*realperc, b1 + (b2-b1)*realperc
end

function db.API:RGBToHex(r, g, b)
	if type(r) ~= 'number' then
		g = r.g
		b = r.b
		r = r.r
	end

	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format('%02x%02x%02x', r*255, g*255, b*255)
end

function db.API:unitColor(unitToken)
	if not UnitExists(unitToken) then
		return unpack(config.unitColor.tapped)
	end

	if UnitIsPlayer(unitToken) then
		return unpack(config.unitColor.class[select(2, UnitClass(unitToken))])
	elseif UnitIsTapped(unitToken) and not UnitIsTappedByPlayer(unitToken) then
		return unpack(config.unitColor.tapped)
	elseif unitToken == 'pet' and GetPetHappiness() then
		return db.API:colorGradient(GetPetHappiness() / 3)
	else
		return unpack(config.unitColor.reaction[UnitReaction(unitToken, 'player')])
	end
end

function db.API:unitPowerColor(unitToken)
	return unpack(config.unitColor.power[select(2, UnitPowerType(unitToken))])
end
