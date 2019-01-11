local db = select(2, ...)
local oUF = db.libraries.oUF

local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local GetQuestDifficultyColor = GetQuestDifficultyColor

local Update = function(self, event, unit)
	if self.unit ~= unit then return end

	local name				= UnitName(unit)
	local level				= UnitLevel(unit)
	local levelColor		= GetQuestDifficultyColor(level)
	local classification	= UnitClassification(unit)

	self.name:setName(self, name, level, levelColor, classification)
end

local Enable = function(self)
	if not self.name then return end

	self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
	return true
end

local Disable = function(self)
	if not self.name then return end

	self:UnRegisterEvent("PLAYER_FLAGS_CHANGED", Update)
end

oUF:AddElement('Name', Update, Enable, Disable)
