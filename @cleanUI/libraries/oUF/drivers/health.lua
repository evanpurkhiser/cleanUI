local db = select(2, ...)
local oUF = db.libraries.oUF

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local SetHealth = function(self, event, unit)
	if self.unit ~= unit then return end

	local min = UnitHealth(unit)
	local max = UnitHealthMax(unit)

	self.health:setHealth(self, unit, min, max)
end

local Update = function(self, event, unit)
	if self.unit ~= unit then return end

	self.health:update(self, unit)
	SetHealth(self, event, unit)
end

local Enable = function(self)
	if not self.health then return end

	self:RegisterEvent('UNIT_HEALTH',		SetHealth)
	self:RegisterEvent('UNIT_MAXHEALTH',	SetHealth)
	self:RegisterEvent('UNIT_HAPPINESS',	Update)
	self:RegisterEvent('UNIT_FACTION',		Update)

	return true
end

local Disable = function(self)
	if not self.health then return end

	self:UnregisterEvent('UNIT_HEALTH',		SetHealth)
	self:UnregisterEvent('UNIT_MAXHEALTH',	SetHealth)
	self:UnregisterEvent('UNIT_HAPPINESS',	Update)
	self:UnregisterEvent('UNIT_FACTION',	Update)
end

oUF:AddElement('Health', Update, Enable, Disable)
