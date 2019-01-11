--[[
	math.lua
	A helper designed to make dealing with numbers simpler

	API Functions:
	 - formatNumber
		param  | n - a unformated number
		return | formated number as a string

	 - formatTime
		param  | time - a time in seconds
		return | formated time as a string

	 - formatTime
		param  | time - a ammount of copper
		return | formated cost in gold / silver / copper

	 - formatMemory
		param  | bytes - a number of bytes
		return | formated memory with suffix
]]--

local db = select(2, ...)
local config = db.config.API

function db.API:formatNumber(n)
	if n >= 1000000 then
		return ('%.1fm'):format(n/1000000)
	elseif n >= 10000 then
		return ('%.1fk'):format(n/1000)
	end
	return n..''
end

function db.API:formatTime(time)
	local d = floor((time / 86400) + .5)
	local h = time >= 3570 and floor((time / 3600) + .5) or 0
	local m = floor((time / 60) + .5)
	local s = time

	if d > 0 then
		return ('%1dd'):format(d)
	elseif h > 0 then
		return ('%1dh'):format(h)
	elseif m > 0 and s > 59 then
		return ('%1dm'):format(m)
	end
	return ('%1ds'):format(s)
end

function db.API:formatGold(cost)
	local gold = floor(cost / 10000)
	local silver = mod(floor(cost / 100), 100)
	local copper = mod(floor(cost), 100)

	if gold > 0 then
		return ('%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fc|r'):format(gold, silver, copper)
	elseif silver > 0 then
		return ('%s|cffc7c7cfs|r %s|cffeda55fc|r'):format(silver, copper)
	end
	return ('%s|cffeda55fc|r'):format(copper)
end

function db.API:formatMemory(bytes)
		bytes = bytes > 0 and bytes * 1024 or 0.001

		local s = {'B', 'Kb', 'MB', 'GB', 'TB'}
		local e = floor(abs(log(bytes)/log(1024))) or 0
		return format('%.1f '..s[e+1], (bytes/1024^e))
end
