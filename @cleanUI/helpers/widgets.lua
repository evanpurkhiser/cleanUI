--[[
	colors.lua
	A helper designed to make some common tasks simpler

	API Functions:
	 - cleanBackdrop
		param  | frame - The frame to apply the backdrop too
		return | The frame object
	 - ease
		param  | statusBar - the statusBar to ease the SetValue method
		param  | speed - The higher the number the slower
		This uses the frames OnUpdate handler.. so be carfull
	 - setFade
		param  |  frame - The frame to apply the fade in / out animation too
		param  |  time  - The time it takes to fade in / out
	 - noop
		no operation preformed
]]--

local db = select(2, ...)
local config = db.config.API

function db.API:cleanBackdrop(frame)
	frame:SetBackdrop({
	  bgFile = config.cleanBackdrop.texture,
	  insets = {left = -2, right = -2, top = -2, bottom = -2},
	})
	frame:SetBackdropColor(unpack(config.cleanBackdrop.shading))

	return frame
end

function db.API:ease(statusBar, speed)
	statusBar.SetValue_ = statusBar.SetValue
	statusBar.SetValue	= function(self, value)
		local _, maxVal = self:GetMinMaxValues()
		local width = self:GetWidth()
		self:SetScript('OnUpdate', function(self)
			local limit = 30/GetFramerate()
			local current = self:GetValue()

			self:SetValue_(current + min((value - current) / speed, max(value - current, limit)))

			if abs(current - value) < maxVal * width * .00001  then
				self:SetScript('OnUpdate', nil)
				self:SetValue_(value)
			end
		end)
	end
end

function db.API:noop()
end
