local db = select(2, ...)
local config = db.config.modules.actionBars
local module = {}

module = CreateFrame('Frame', 'cleanActionBars', UIParent, 'SecureHandlerStateTemplate')
module:SetWidth(400)
module:SetPoint(unpack(config.position))

-- Primary actionbar
ActionButton1:ClearAllPoints()
ActionButton1:SetParent(module)
ActionButton1:SetPoint('BOTTOMLEFT')
for i = 2, 12 do
	_G['ActionButton'..i]:SetParent(module)
	_G['ActionButton'..i]:SetPoint('LEFT', _G['ActionButton'..i - 1], 'RIGHT', 8, 0)
end

-- Secondary bar
MultiBarBottomLeft:SetParent(module)
MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint('BOTTOM', ActionButton1, 'TOP', 0, 8)
for i = 2, 12 do
	_G['MultiBarBottomLeftButton'..i]:SetPoint('LEFT', _G['MultiBarBottomLeftButton'..i - 1], 'RIGHT', 8, 0)
end

-- Tertiary bar
MultiBarBottomRight:SetParent(module)
MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint('BOTTOM', MultiBarBottomLeftButton1, 'TOP', 0, 8)
for i = 2, 12 do
	_G['MultiBarBottomRightButton'..i]:SetPoint('LEFT', _G['MultiBarBottomRightButton'..i - 1], 'RIGHT', 8, 0)
end

-- Vehicle Exit Button
module.vehicleExit = CreateFrame("Button", _, module, "SecureHandlerClickTemplate")
db.API:cleanBackdrop(module.vehicleExit)
module.vehicleExit:SetSize(26, 26)
module.vehicleExit:SetPoint('LEFT', ActionButton6, 'RIGHT', 8, 0)
module.vehicleExit:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
module.vehicleExit:GetNormalTexture():SetTexCoord(.25, .75, .25, .75)
module.vehicleExit:RegisterForClicks("AnyUp")
module.vehicleExit:SetScript("OnClick", VehicleExit)
module:SetFrameRef('vehicleExit', module.vehicleExit)

-- Thanks to Tukz for the following code :)
local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [mod:ctrl, nocombat] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

function module.getBar()
	local condition = Page['DEFAULT']
	local class = db.config.playerClass
	local page = Page[class]
	if page then
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

for i = 1, 12 do
	module:SetFrameRef('ActionButton'..i, _G['ActionButton'..i])
end

module:Execute([[
	vehicleExit = self:GetFrameRef('vehicleExit')
	buttons = table.new()
	for i = 1, 12 do
		table.insert(buttons, self:GetFrameRef('ActionButton'..i))
	end
]])

module:SetAttribute("_onstate-page", [[
	for i, button in ipairs(buttons) do
		button:SetAttribute("actionpage", tonumber(newstate))
	end
]])

module:SetAttribute("_onstate-vehicle", [[
	if newstate == 1 then
		vehicleExit:Show()
		self:SetWidth(230)
		for i = 7, 12 do buttons[i]:Hide() end
	else
		vehicleExit:Hide()
		self:SetWidth(400)
		for i = 7, 12 do buttons[i]:Show() end
	end
]])

RegisterStateDriver(module, "page", module.getBar())
RegisterStateDriver(module, "vehicle", "[bonusbar:5] 1; 0")

-- Hide Blizzard Stuff
MainMenuBar:SetScale(0.001)
MainMenuBar:SetAlpha(0)
VehicleMenuBar:SetScale(0.001)
VehicleMenuBar:SetAlpha(0)

db.modules.actionBars = module
