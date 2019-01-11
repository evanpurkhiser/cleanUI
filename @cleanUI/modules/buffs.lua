local db = select(2, ...)
local config = db.config.modules.buffs
local module = {}

function module:updateBuffAnchors()
	for i = 1, BUFF_ACTUAL_DISPLAY do
		local buff		= _G['BuffButton'..i];
		local icon		= _G['BuffButton'..i..'Icon']
		local duration	= _G['BuffButton'..i..'Duration']
		local count		= _G['BuffButton'..i..'Count']

		if icon and not buff:GetBackdrop() then
			icon:SetTexCoord(.1, .9, .1, .9)
			icon:SetDrawLayer('OVERLAY')

			duration:SetFont(unpack(config.duration.font))
			duration:SetDrawLayer('OVERLAY')
			duration:ClearAllPoints()
			duration:SetPoint(unpack(config.duration.position))

			count:SetFont(unpack(config.count.font))
			count:ClearAllPoints()
			count:SetDrawLayer('OVERLAY')
			count:SetPoint(unpack(config.count.position))

			buff:SetHeight(26)
			buff:SetWidth(26)

			db.API:cleanBackdrop(buff)
		end

		buff:SetAlpha(1)

		buff:ClearAllPoints()
		if i == 20 then
			buff:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -22, -54)
		elseif i == 1 then
			buff:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -22, -22)
		else
			buff:SetPoint('RIGHT', _G['BuffButton'..(i-1)], 'LEFT', -8, 0)
		end
	end
end

function module:updateDebuffAnchors(index)
	_G[self..index]:Hide()
end

function module:updateDurationText(remaining)
	local duration = _G[self:GetName()..'Duration']
	duration:SetTextColor(1, 1, 1)
	duration:SetText(db.API:formatTime(remaining))
end

hooksecurefunc('BuffFrame_UpdateAllBuffAnchors', module.updateBuffAnchors)
hooksecurefunc('DebuffButton_UpdateAnchors', module.updateDebuffAnchors)
hooksecurefunc('AuraButton_UpdateDuration', module.updateDurationText)
hooksecurefunc('AuraButton_OnUpdate', function(self) self:SetAlpha(1) end)

db.modules.buffs = module
