local db = select(2, ...)
local config = db.config.modules.cooldowns
local module = {}

-- Update the cooldown timer text
function module:updateCooldown(elapsed)
	local remaining = self.endTime - GetTime()
	local text = self.text
	if remaining > 0 then
		text:SetText(db.API:formatTime(remaining))
	else
		text:Hide()
		text:SetText()
	end
end

-- Create the fontString
function module:createText()
	local text = self:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER')
	self.text = text
	self:SetScript('OnUpdate', module.updateCooldown)
	return text
end

-- Called when a cooldown spiral is set
function module:setCooldown(start, duration)
	if start > 0 and duration > config.minDuration then
		self.endTime  = start + duration

		local text = self.text or module.createText(self)
		text:SetFont(unpack(config.font))
		text:SetPoint(unpack(config.position))
		text:Show()
	else
		if self.text then
			self.text:Hide()
		end
	end
end

-- Hook the cooldwon spiral
local methods = getmetatable(ActionButton1Cooldown).__index
hooksecurefunc(methods, 'SetCooldown', module.setCooldown)

db.modules.cooldowns = module
