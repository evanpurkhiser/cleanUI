--[[
	events.lua
	A helper designed to make the event driven nature of Warcraft AddOns much simpler

	API Functions:
	 - RegisterEvents
		param  | function - the function to execute upon the event firing
		param  | events - (vararg) A list of one or more events to be monitered
		return | none

	 - HandleEventCall
		descr  |
		param  | event - The event being handled
		param  | eventArgs - Arguments passed when the event is fired
]]--

local db = select(2, ...)
local config = db.config.API

function db.API:RegisterEvents(func, ...)
	if type(func) ~= 'function' then return end
	for i = 1, select('#', ...) do
		local event = select(i, ...)
		if type(event) ~= 'string' then return end

		self.events:RegisterEvent(event)
		if not self.events[event] then
			self.events[event] = {}
		end
		tinsert(self.events[event], func)
	end
end

function db.API:handleEventCall(event, ...)
	if not self[event] then return end
	for i = 1, #self[event] do
		self[event][i](self, event, ...)
	end
end

db.API.events = {}
db.API.events = CreateFrame('Frame')
db.API.events:SetScript('OnEvent', db.API.handleEventCall)
