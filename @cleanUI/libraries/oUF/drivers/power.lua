local db = select(2, ...)
local oUF = db.libraries.oUF

local UnitMana = UnitMana
local UnitManaMax = UnitManaMax

local SetPower = function(self, event, unit)
	if self.unit ~= unit then return end

	local min = UnitPower(unit)
	local max = UnitPowerMax(unit)

	self.power:setPower(self, unit, min, max)
end

local Update = function(self, event, unit)
	if self.unit ~= unit then return end

	self.power:update(self, unit)
	SetPower(self, event, unit)
end

local Enable = function(self)
	if not self.power then return end

	self:RegisterEvent('UNIT_DISPLAYPOWER',		Update)
	self:RegisterEvent('UNIT_POWER',			SetPower)
	self:RegisterEvent('UNIT_MAXPOWER',			SetPower)

	return true
end

local Disable = function(self)
	if not self.power then return end

	self:UnregisterEvent('UNIT_DISPLAYPOWER',	Update)
	self:UnregisterEvent('UNIT_POWER',			SetPower)
	self:UnregisterEvent('UNIT_MAXPOWER',		SetPower)
end

oUF:AddElement('Power', Update, Enable, Disable)
