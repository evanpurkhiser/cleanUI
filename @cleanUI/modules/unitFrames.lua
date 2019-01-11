local db = select(2, ...)
local config = db.config.modules.unitFrames
local oUF = db.libraries.oUF
local module = {}

-- Setup the right-click menu
local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if unit == "party" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif _G[cunit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

-- Setup the health update (unit change, faction change)
local hp_update = function(bar, frame, unit)
	-- Setup the bar color
	r, g, b = db.API:unitColor(unit)
	bar:SetStatusBarColor(r, g, b)
	bar.bg:SetVertexColor(r, g, b, .4)
end

-- Setup the health value update
local hp_value_update = function(bar, frame, unit, min, max)
	-- Set the status text for being dead (or alive)
	-- This is a work-around for the PLAYER_DEAD event
	-- firing on release not death and PLAYER_ALIVE not firing
	-- upon being resurected
	if (bar:GetValue() < 3 or min < 3) and frame.PLAYER_DEAD then
		frame:PLAYER_DEAD(nil, unit)
	end

	-- Set the bar value
	bar:SetMinMaxValues(0, max)
	bar:SetValue(min)

	-- Setup the health text
	if bar.text and not bar.text.status then
		-- Get health color gradient
		r, g, b = db.API:colorGradient(min / max)

		-- Set the text value (if there is no status)
		if unit == "player" then
			bar.text:SetText(format("|cff%02x%02x%02x%.1f|r %s", r*255, g*255, b*255, min/max*100, db.API:formatNumber(min)))
		else
			bar.text:SetText(format("%s |cff%02x%02x%02x%.1f|r", db.API:formatNumber(min), r*255, g*255, b*255, min/max*100))
		end
	end
end

-- Setup the power update (unit change)
local pwr_update = function(bar, frame, unit)
	-- Only show the bar if nessicary
	if UnitManaMax(unit) == 0 then
		bar:Hide()
		frame.health:SetPoint("BOTTOMRIGHT")
	else
		bar:Show()
		frame.health:SetPoint("BOTTOMRIGHT", 0, 5)
	end

	-- Set bar color
	r, g, b = db.API:unitPowerColor(unit)

	bar:SetStatusBarColor(r, g, b)
	bar.bg:SetVertexColor(r, g, b, .4)
end

-- Setup the power value update
local pwr_value_update = function(bar, frame, unit, min, max)
	-- Set the power value
	bar:SetMinMaxValues(0, max)
	bar:SetValue(min)
end

-- Castbar starting new cast
local cb_start_cast = function(bar, unit, name)
	-- Setup the castbar color
	r, g, b = db.API:unitColor(unit)
	bar:SetStatusBarColor(r, g, b)
	bar.bg:SetVertexColor(r, g, b, .4)

	-- Setup the cast name
	bar.name:SetText(name)

	-- Show the castbar
	bar:Show()
end

-- Castbar ending a cast
local cb_end_cast = function(bar, unit)
	bar:Hide()
end

-- Castbar value update
local cb_value_update = function(bar, min, max)
	bar:SetValue(min / max)
	bar.time:SetFormattedText("%.1f / %.1f", min, max)
end

-- Set the status text for certian events
local set_status = function(text, disconnect, dead, ghost, afk)
	if dead then text:SetText("Dead") end
	if ghost then text:SetText("Ghost") end
	if afk then text:SetText("AFK") end
	if disconnect then text:SetText("Offline") end
end

-- Reset the status text if there is no status
local status_reset = function(text, self, ...)
	self:UNIT_HEALTH(...)
end

-- Setup the threat value updatee
local threat_update = function(text, frame, status, threat)
	if not threat or UnitIsPlayer("Target") or GetNumPartyMembers() < 1 then
		text:Hide()
		return
	end

	text:Show()
	text:SetText(math.floor(threat + .5))
	text:SetTextColor(GetThreatStatusColor(status))
	text:SetAlpha(threat / 100)
end

-- Setup the combo points value update
local cp_update = function(text, frame, points)
	r, g, b = db.API:colorGradient(points / 5)
	text:SetText((points > 0) and points)
	text:SetTextColor(r, g, b)
end

-- Set the user name
local set_long_name = function(text, frame, name, level, color, classification)
	-- Uknown level mob
	if level == -1 then
		level = '??'
		levelColor = {
			r = 1,
			g = 0,
			b = 0
		}
	end

	-- Get the classification
	for i,v in pairs(config.classifications) do
		if classification == i then
			classification = v
			break
		end
	end

	-- Set the text
	text:SetFormattedText("%s |cff%s%s%s|r", name, db.API:RGBToHex(color), level, classification)
end

-- Create a new aura icon
local newAuraIcon = function(self)
	local button = CreateFrame("Button", _,self)
	db.API:cleanBackdrop(button)

	-- Setup hover
	button:SetScript("OnEnter", function(self)
		if(not self:IsVisible()) then return end
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:SetUnitAura(self.unit, self.id, self.filter)
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Texture
	button.icon = button:CreateTexture()
	button.icon:SetAllPoints(button)
	button.icon:SetTexCoord(.08, .92, .08, .92)

	-- Cooldown
	button.cd = CreateFrame("Cooldown", nil, button)
	button.cd:SetAllPoints(button)

	-- Count
	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("TOPRIGHT", button, 2, 0)
	button.count:SetFont(db.config.modules.unitFrames.font, 11, "OUTLINE")

	-- Stealable icon
	button.stealable = button.cd:CreateTexture('', 'OVERLAY')
	button.stealable:SetSize(15, 15)
	button.stealable:SetPoint('TOPLEFT', -6, 5)
	button.stealable:SetTexture('Interface\\Raidframe\\ReadyCheck-Ready')
	button.stealable:Hide()

	return button
end

local addAuraIcon = function(auras, unit, auraInfo)
	local aura = auras[auras.index]

	if auraInfo then
		-- Set button info
		aura.unit = unit
		aura.id = auraInfo[1]
		aura.filter = auraInfo[2]
		aura.icon:SetTexture(auraInfo[3][3])
		aura.count:SetText((auraInfo[3][4] > 1) and auraInfo[3][4])
		CooldownFrame_SetTimer(aura.cd, auraInfo[3][7] - auraInfo[3][6], auraInfo[3][6], 1)

		-- Check for spell steal
		if auraInfo[3][9] then
			aura.stealable:Show()
		else
			aura.stealable:Hide()
		end

		-- Show the button
		aura:Show()
	end

	-- Increment the index
	auras.index = auras.index + 1
end

local resetAuraIcons = function(auras)
	for i = 1, #auras do
		auras[i]:Hide()
	end

	auras.index = 1
end

local update_aura_buttons = function(auras, frame, unit)
	resetAuraIcons(auras)

	if unit == 'player' then
		-- Player debuffs only
		for i = 1, #auras - auras.index + 1 do
			local aura = {UnitAura(unit, i, 'HARMFUL')}
			if not aura[1] then break end
			addAuraIcon(auras, unit, {i, 'HARMFUL', aura})
		end
	elseif unit == 'target' then
		-- Add target buffs...
		for i = 1, #auras - auras.index + 1 do
			local aura = {UnitAura(unit, i, 'HELPFUL')}
			if not aura[1] then break end
			addAuraIcon(auras, unit, {i, 'HELPFUL', aura})
		end

		-- Add a spacer
		if auras.index ~= 1 then
			addAuraIcon(auras, unit, false)
		end

		-- Show all buffs for friendly units
		if UnitIsFriend('player', 'target') then
			for i = 1, #auras - auras.index + 1 do
				local aura = {UnitAura(unit, i, 'HARMFUL')}
				if not aura[1] then break end
				addAuraIcon(auras, unit, {i, 'HARMFUL', aura})
			end
		else
			-- Add target debuffs by the player
			for i = 1, #auras - auras.index + 1 do
				local aura = {UnitAura(unit, i, 'PLAYER|HARMFUL')}
				if not aura[1] then break end
				addAuraIcon(auras, unit, {i, 'PLAYER|HARMFUL', aura})
			end

			-- Add in the targest selected other debuffs
			for i = 1, #auras - auras.index + 1 do
				local aura = {UnitAura(unit, i, 'HARMFUL')}
				if not aura[1] then break end

				local spells = config.auras.nonPlayerTargetDebuffs[db.config.playerClass]
				if not spells then break end

				for _, spellID in ipairs(spells) do
					if aura[11] == spellID then
						addAuraIcon(auras, unit, {i, 'HARMFUL', aura})
						break
					end
				end
			end
		end
	end
end

-- Setup all frames / text / event handlers
local cleanOUF = function(self, unit)
	db.API:cleanBackdrop(self)

	-- Unit frame menu
	self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	-- Unit Health
	local hp = CreateFrame("StatusBar", _, self)
	hp:SetStatusBarTexture(config.texture)
	hp:SetPoint("TOPLEFT")
	hp:SetPoint("BOTTOMRIGHT")
	db.API:ease(hp, 6)

	-- Unit Health Background
	hp.bg = hp:CreateTexture(nil, "BORDER")
	hp.bg:SetAllPoints(hp)
	hp.bg:SetTexture(config.texture)

	-- Setup health event handlers
	self.health = hp
	self.health.update    = hp_update
	self.health.setHealth = hp_value_update

	-- Player and Target
	if unit == "player" or unit == "target" then
		-- Unit Health text value
		hp.text = self:CreateFontString(nil, "OVERLAY")
		hp.text:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
		hp.text:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 2)
		hp.text:SetFont(config.font, 11, "OUTLINE")
		hp.text:SetJustifyH("LEFT")

		-- Setup the status text events
		self.statusText = self.health.text
		self.statusText.setStatus = set_status
		self.statusText.reset = status_reset

		-- Unit Power
		local pwr = CreateFrame("StatusBar", _, self)
		pwr:SetStatusBarTexture(config.texture)
		pwr:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -1)
		pwr:SetPoint("BOTTOMRIGHT")
		db.API:ease(pwr, 6)

		-- Unit Power Background
		pwr.bg = pwr:CreateTexture(nil, "BORDER")
		pwr.bg:SetAllPoints(pwr)
		pwr.bg:SetTexture(config.texture)

		-- Setup power event handler
		self.power = pwr
		self.power.update   = pwr_update
		self.power.setPower = pwr_value_update

		-- Unit Castbar
		local cb = CreateFrame("StatusBar", _, self)
		cb:SetStatusBarTexture(config.texture)
		cb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 16)
		cb:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 16)
		cb:SetHeight(12)
		cb:SetMinMaxValues(0, 1)
		db.API:cleanBackdrop(cb)

		-- Unit Castbar Background
		cb.bg = cb:CreateTexture(nil, "BORDER")
		cb.bg:SetAllPoints(cb)
		cb.bg:SetTexture(config.texture)

		-- Unit Castbar cast name
		cb.name = cb:CreateFontString(nil, "OVERLAY")
		cb.name:SetPoint("BOTTOMLEFT", cb, "TOPLEFT", -2, 2)
		cb.name:SetFont(config.font, 11, "OUTLINE")
		cb.name:SetJustifyH("LEFT")

		-- Unit Castbar cast time
		cb.time = cb:CreateFontString(nil, "OVERLAY")
		cb.time:SetPoint("BOTTOMRIGHT", cb, "TOPRIGHT", 2, 2)
		cb.time:SetFont(config.font, 11, "OUTLINE")
		cb.time:SetJustifyH("RIGHT")

		-- Setup casting bar events
		self.castbar = cb
		self.castbar.startCast = cb_start_cast
		self.castbar.endCast   = cb_end_cast
		self.castbar.setValue  = cb_value_update

		-- Unit Raid icon
		local rif = CreateFrame("Frame", _, hp)
		rif:SetAllPoints(hp)

		-- Setup the raid icon texture
		rif.icon = rif:CreateTexture("OVERLAY")
		rif.icon:SetHeight(28)
		rif.icon:SetWidth(28)
		rif.icon:SetPoint("CENTER")

		-- Setup event handler
		self.raidIcon = rif.icon

		-- Setup aura icon grid
		self.auras = {}
		self.auras.index = 1
		self.auras.update = update_aura_buttons

		-- Populate aura grid
		for i = 1, config.auras.total do
			-- Create a new button
			local button = newAuraIcon(self)
			button:SetHeight(26)
			button:SetWidth(26)
			button:Hide()

			-- Positioning
			if i == 1 then
				button:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
			elseif i % 10 == 1 then
				button:SetPoint("TOPLEFT", self.auras[i-10], "BOTTOMLEFT", 0, -6)
			else
				button:SetPoint("LEFT", self.auras[i-1], "RIGHT", 6, 0)
			end

			-- Save the button
			self.auras[i] = button
		end

		-- Player Specific config
		if unit == "player" then
			-- Move the player health to the right
			hp.text:SetJustifyH("RIGHT")

			-- Threat percentage
			local threat = self:CreateFontString(nil, "OVERLAY")
			threat:SetPoint("RIGHT", self, "LEFT", -2, 0)
			threat:SetFont(config.font, 20, "OUTLINE")

			-- Setup threat event handlers
			self.threat = threat
			self.threat.update = threat_update

			-- Temp Enchants
			for i = 1, 3 do
				_G["TempEnchant"..i.."Icon"]:Hide()
				_G["TempEnchant"..i.."Count"]:Hide()
				_G["TempEnchant"..i.."Border"]:Hide()

				_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
				_G["TempEnchant"..i.."Duration"]:SetFont(config.font, 11, "OUTLINE")
				_G["TempEnchant"..i.."Duration"]:SetShadowColor(0, 0, 0, 0)

				_G["TempEnchant"..i]:SetAllPoints(_G["TempEnchant"..i.."Duration"])
			end

			TempEnchant1Duration:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
			TempEnchant2Duration:SetPoint("LEFT", TempEnchant1Duration, "RIGHT", -2, 0)
			TempEnchant3Duration:SetPoint("LEFT", TempEnchant2Duration, "RIGHT", -2, 0)

			hooksecurefunc("TempEnchantButton_OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetInventoryItem("player", self:GetID())
			end)
		end

		-- Target Specific config
		if unit == "target" then
			-- Setup the unit name
			local name = self:CreateFontString(nil, "OVERLAY")
			name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
			name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 2)
			name:SetFont(config.font, 11, "OUTLINE")
			name:SetJustifyH("RIGHT")

			-- Setup name / level event listeners
			self.name = name
			self.name.setName = set_long_name

			-- Combo point counter
			local cp = self:CreateFontString(nil, "OVERLAY")
			cp:SetPoint("LEFT", self, "RIGHT", 2, 0)
			cp:SetFont(config.font, 20, "OUTLINE")

			-- Setup combo point event listener
			self.cPoints = cp
			self.cPoints.setPoints = cp_update
		end

		self.Auras = true
		self.Buffs = true
		self.Debuffs = true
	end

	-- Target of Target
	if unit == "targettarget" then
		-- Setup the unit name
		local name = self:CreateFontString(nil, "OVERLAY")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 2)
		name:SetFont(config.font, 11, "OUTLINE")
		name:SetJustifyH("CENTER")

		-- Setup name event listener
		self.name = name
		self.name.setName = function(text, frame, name)
			text:SetText(name)
		end
	end

	-- Focus Frame
	if unit == "focus" then
		-- Setup the unit name
		local name = self:CreateFontString(nil, "OVERLAY")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 2)
		name:SetFont(config.font, 11, "OUTLINE")
		name:SetJustifyH("LEFT")

		-- Setup name / level event listeners
		self.name = name
		self.name.setName = set_long_name

		-- Unit Health text value
		hp.text = self:CreateFontString(nil, "OVERLAY")
		hp.text:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 2)
		hp.text:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 2)
		hp.text:SetFont(config.font, 11, "OUTLINE")
		hp.text:SetJustifyH("RIGHT")

		-- Setup the status text events
		self.statusText = self.health.text
		self.statusText.setStatus = set_status
		self.statusText.reset = status_reset

		-- Unit Raid icon
		local rif = CreateFrame("Frame", _, hp)
		rif:SetAllPoints(hp)

		-- Setup the raid icon texture
		rif.icon = rif:CreateTexture("OVERLAY")
		rif.icon:SetHeight(20)
		rif.icon:SetWidth(20)
		rif.icon:SetPoint("CENTER")

		-- Setup event handler
		self.raidIcon = rif.icon
	end

	-- Raid and Party
	if not unit then
		-- Unit Power
		local pwr = CreateFrame("StatusBar", _, self)
		pwr:SetStatusBarTexture(config.texture)
		pwr:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -1)
		pwr:SetPoint("BOTTOMRIGHT")
		db.API:ease(pwr, 6)

		-- Unit Power Background
		pwr.bg = pwr:CreateTexture(nil, "BORDER")
		pwr.bg:SetAllPoints(pwr)
		pwr.bg:SetTexture(config.texture)

		-- Setup power event handler
		self.power = pwr
		self.power.update   = pwr_update
		self.power.setPower = pwr_value_update

	end
end

-- Register Style
oUF:RegisterStyle("cleanOUF", cleanOUF)

-- Create units frames
for _, unit in ipairs(config.units) do
	if unit.type == 'unit' then
		local frame = oUF:Spawn(unit.unitID)
		frame:SetPoint(unpack(unit.position))
		frame:SetSize(unpack(unit.size))
	elseif unit.type == 'group' then

	end
end

db.modules.unitFrames = module
