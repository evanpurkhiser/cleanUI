local db = select(2, ...)
local config = db.config.modules.tracker
local module = {}


--[[

local test = function(...)
	print(...)
end


db.API:RegisterEvents(test, 'UNIT_AURA', 'UNIT_SPELLCAST_SUCCEEDED', 'PLAYER_TARGET_CHANGED')





-- Setup all of the trackers
for i, spell in pairs(config) do

	-- First create the icon
	local tracker = CreateFrame('Frame', _, UIParent)

	-- Positioning and backdrop
	tracker:SetPoint(unpack(spell.position))
	tracker:SetWidth(spell.size)
	tracker:SetHeight(spell.size)
	db.API:cleanBackdrop(tracker)

	-- Tracker icon
	tracker.icon = tracker:CreateTexture('ARTWORK')
	tracker.icon:SetTexCoord(.08, .92, .08, .92)
	tracker.icon:SetTexture(select(3, GetSpellInfo(spell.id)))
	tracker.icon:SetAllPoints(tracker)

	-- Tracker timer
	tracker.timer = CreateFrame('Cooldown', nil, tracker)
	tracker.timer:SetAllPoints(tracker)

end

db.modules.tracker = module

]]--
