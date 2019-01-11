local db = select(2, ...)
local oUF = db.libraries.oUF


local Update = function(self, event, unit)
	if unit ~= self.unit then return end

	self.auras:update(self, unit)
end

local Enable = function(self)
	if not self.auras then return end

	self:RegisterEvent("UNIT_AURA", Update)
	return true
end

local Disable = function(self)
	if not self.auras then return end

	self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement('Aura', Update, Enable, Disable)
