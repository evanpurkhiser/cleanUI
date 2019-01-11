local db = select(2, ...)
local config = db.config.modules.nameplates
local module = {}

module = CreateFrame('Frame')

-- Update the nameplate
function module:updateNameplate(frame)
	if not frame then frame = self end

	local r, g, b = frame.healthBar:GetStatusBarColor()
	if g + b == 0 then
		r, g, b = unpack(config.unitColor.reaction[1])
	elseif r + b == 0 then
		r, g, b = unpack(config.unitColor.reaction[5])
	elseif r + g == 0 then
		r, g, b = 0, .3, .6
	elseif 2 - (r + g) < 0.05 and b == 0 then
		r, g, b = unpack(config.unitColor.reaction[4])
	end

	frame.healthBar.r = r
	frame.healthBar.g = g
	frame.healthBar.b = b
	frame.healthBar:SetStatusBarColor(r, g, b)

	-- Setup healthbar position
	frame.healthBar:ClearAllPoints()
	frame.healthBar:SetPoint('CENTER', frame.healthBar:GetParent())
	frame.healthBar:SetHeight(7)
	frame.healthBar:SetWidth(130)

	-- Setup castbar positon
	frame.castBar:ClearAllPoints()
	frame.castBar:SetPoint('TOPLEFT', frame.healthBar, 'BOTTOMLEFT', 0, -1.5)
	frame.castBar:SetPoint('TOPRIGHT', frame.healthBar, 'BOTTOMRIGHT', 0, -1.5)
	frame.castBar:SetPoint('BOTTOM', frame.healthBar, 'BOTTOM', 0, -5)

	-- Setup name and level
	local r, g, b = frame.levelText:GetTextColor()
	local level = frame.boss:IsShown() and '??' or (frame.levelText:GetText() or '')..(frame.elite:IsShown() and '+' or '')
	if frame.boss:IsShown() then
		r, g, b = 1, 0, 0
	end
	frame.nameText:SetFormattedText('%s |cff%s%s|r', frame.nameText:GetText(), db.API:RGBToHex(r, g, b), level)
	frame.levelText:Hide()
end

-- Style the nameplate
function module:styleNameplate(frame)
	frame.Styled = true

	frame.healthBar, frame.castBar = frame:GetChildren()
	local healthBar, castBar = frame.healthBar, frame.castBar
	local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()

	-- For updating name and level
	frame.levelText = levelTextRegion
	frame.nameText = nameTextRegion

	-- Setup hp bar bg
	healthBar:SetStatusBarTexture(config.texture)
	healthBar.bg = healthBar:CreateTexture(nil, 'BORDER')
	healthBar.bg:SetAllPoints(healthBar)
	healthBar.bg:SetTexture(config.texture)
	healthBar.bg:SetVertexColor(unpack(config.shading))

	-- Setup cast bar bg
	castBar:SetStatusBarTexture(config.texture)
	castBar.bg = castBar:CreateTexture(nil, 'BORDER')
	castBar.bg:SetAllPoints(castBar)
	castBar.bg:SetTexture(config.texture)
	castBar.bg:SetVertexColor(unpack(config.shading))

	-- Setup health text
	nameTextRegion:SetFont(unpack(config.font))
	nameTextRegion:SetShadowOffset(0, 0)
	nameTextRegion:ClearAllPoints()
	nameTextRegion:SetPoint('BOTTOM', healthBar, 'TOP', 0, 1)

	-- Setup Icon
	spellIconRegion:ClearAllPoints()
	spellIconRegion:SetPoint('TOPLEFT', healthBar, 'TOPRIGHT', 1.2, 0)
	spellIconRegion:SetTexCoord(.08, .92, .08, .92)
	spellIconRegion:SetHeight(12)
	spellIconRegion:SetWidth(12)

	-- Check if the mob is an elite or a boss
	frame.elite = stateIconRegion
	frame.boss = bossIconRegion

	-- Hide unwanted textures
	glowRegion:SetTexture(nil)
	overlayRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	stateIconRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)
	highlightRegion:SetTexture(nil)

	frame:SetScript('OnShow', module.updateNameplate)

	-- Make sure the color stays right
	frame.refresh = 0
	frame:SetScript('OnUpdate', function(self, update)
		self.refresh = self.refresh + update
		if self.refresh > 1 then
			frame.healthBar:SetStatusBarColor(self.healthBar.r, self.healthBar.g, self.healthBar.b)
		end
	end)
end

-- Check if the frame is a nameplate
function module:isNameplate(frame)
	if frame:GetName() or frame.Styled then return end

	local overlayRegion = select(2, frame:GetRegions())
	return overlayRegion and overlayRegion:GetObjectType() == 'Texture' and overlayRegion:GetTexture() == [[Interface\Tooltips\Nameplate-Border]]
end

-- Watch for new nameplates
function module:checkFrames(update)
	self.elapsed = self.elapsed + update
	if self.elapsed > 0.1 then
		self.elapsed = 0

		if WorldFrame:GetNumChildren() ~= self.numChildren then
			self.numChildren = WorldFrame:GetNumChildren()
			for i = 1, self.numChildren do
				local frame = select(i, WorldFrame:GetChildren())

				if self:isNameplate(frame) then
					self:styleNameplate(frame)
					self:updateNameplate(frame)
				end
			end
		end
	end
end
module.elapsed = 0
module:SetScript('OnUpdate', module.checkFrames)

db.modules.nameplates = module
