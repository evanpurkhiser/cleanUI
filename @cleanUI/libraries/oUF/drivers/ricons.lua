local db = select(2, ...)
local oUF = db.libraries.oUF

local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local Update = function(self, event)
	local icon = self.raidIcon
	local index = GetRaidTargetIndex(self.unit)

	if index then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

local Enable = function(self)
	if not self.raidIcon or not self.raidIcon.SetTexture then return end

	self:RegisterEvent('RAID_TARGET_UPDATE', Update)
	self.raidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')

	return true
end

local Disable = function(self)
	if not self.raidIcon or not self.raidIcon.SetTexture then return end

	self:UnregisterEvent('RAID_TARGET_UPDATE', Update)
end

oUF:AddElement('RaidIcon', Update, Enable, Disable)
