local db = select(2, ...)
local oUF = db.libraries.oUF

local Update = function(self, event, unit)
	local points = GetComboPoints(UnitInVehicle("player") and "vehicle" or "player", "target")

	self.cPoints:setPoints(self, points)
end

local Enable = function(self)
	if not self.cPoints then return end

	self:RegisterEvent("UNIT_COMBO_POINTS", Update)
	return true
end

local Disable = function(self)
	if not self.cPoints then return end

	self:UnregisterEvent("UNIT_COMBO_POINTS", Update)
end

oUF:AddElement('ComboPoints', Update, Enable, Disable)
