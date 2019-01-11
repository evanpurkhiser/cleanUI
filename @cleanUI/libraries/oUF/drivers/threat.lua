local db = select(2, ...)
local oUF = db.libraries.oUF

local UnitDetailedThreatSituation	= UnitDetailedThreatSituation
local GetThreatStatusColor			= GetThreatStatusColor

local Update = function(self, event, unit)
	local status, percent = select(2, UnitDetailedThreatSituation("Player", "Target"))

	self.threat:update(frame, status, percent)
end

local Enable = function(self)
	if not self.threat then return end

	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Update)
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	return true
end

local Disable = function(self)
	if not self.threat then return end

	self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE", Update)
	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
end

oUF:AddElement('Threat', Update, Enable, Disable)
