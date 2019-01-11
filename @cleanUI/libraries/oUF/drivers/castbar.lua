local db = select(2, ...)
local oUF = db.libraries.oUF

-- Upon spellcast start
local start_cast = function(self, event, unit, spellName)
	if self.unit ~= unit then return end

	-- Check if it is a spell cast
	local name, _, _, _, startTime, endTime = UnitCastingInfo(unit)
	local channeling = false

	-- Ok, it might be a channeling cast
	if not name then
		name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
		channeling = true
	end

	-- Only start if there is a cast
	if not name then return end

	-- Fix start/end time
	endTime = endTime / 1000
	startTime = startTime / 1000

	-- Save the casting info
	self.castbar.startTime = channeling and endTime or startTime
	self.castbar.totalTime = endTime - startTime

	-- Send the start cast callback
	self.castbar:startCast(unit, name)

	-- Start the update timer
	self.castbar:SetScript('OnUpdate', function(self, elapsed)
		self:setValue(abs(GetTime() - self.startTime), self.totalTime)
	end)
end

-- Upon spellcast end
local end_cast = function(self, event, unit, spellName)
	if self.unit ~= unit then return end

	-- Send the end callback
	self.castbar:endCast(unit)

	-- Stop the update timer
	self.castbar:SetScript('OnUpdate', nil)
end

-- Upon unit change
local Update = function(self, event, unit)
	end_cast(self, event, unit, nil)
	start_cast(self, event, unit, nil)
end

local Enable = function(self)
	if not self.castbar then return false end

	self:RegisterEvent("UNIT_SPELLCAST_START",					start_cast)
	self:RegisterEvent("UNIT_SPELLCAST_STOP",					end_cast)
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED",				start_cast)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START",			start_cast)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE",			start_cast)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP",			end_cast)

	-- Unregister the blizzard castbar
	CastingBarFrame:UnregisterAllEvents()
	CastingBarFrame:Hide()
	CastingBarFrame.Show = db.API.noop

	-- Unregister the blizzard pet casting bar
	PetCastingBarFrame:UnregisterAllEvents()
	PetCastingBarFrame:Hide()
	PetCastingBarFrame.Show = db.API.noop

	return true
end

local Disable = function(self)
	if not self.castbar then return end

	self:UnRegisterEvent("UNIT_SPELLCAST_START",				start_cast)
	self:UnRegisterEvent("UNIT_SPELLCAST_STOP",					end_cast)
	self:UnRegisterEvent("UNIT_SPELLCAST_DELAYED",				start_cast)
	self:UnRegisterEvent("UNIT_SPELLCAST_CHANNEL_START",		start_cast)
	self:UnRegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE",		start_cast)
	self:UnRegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP",			end_cast)
end

oUF:AddElement('Castbar', Update, Enable, Disable)
