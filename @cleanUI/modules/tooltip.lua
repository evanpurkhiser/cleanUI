local db = select(2, ...)
local config = db.config.modules.tooltip
local module = {}

-- Configure different tooltips
local tooltips = {
	'GameTooltip',
	'ItemRefTooltip',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
	'ShoppingTooltip3',
	'DropDownList1MenuBackdrop',
	'DropDownList2MenuBackdrop',
	'WorldMapTooltip'
}

for i = 1, #tooltips do
	local backdrop = {
		bgFile = config.texture,
		edgeFile = 0, tile = 0, tileSize = 0, edgeSize = 0,
		insets = {left = 2, right = 2, top = 3, bottom = 2}
	}

	_G[tooltips[i]]:SetBackdrop(backdrop)
	_G[tooltips[i]]:SetScript('OnShow', function(self) self:SetBackdropColor(unpack(config.shading)) end)
	_G[tooltips[i]]:SetScale(config.scale)
end

-- Hide PVP text
PVP_ENABLED = ''

-- Status bar
GameTooltipStatusBar:SetStatusBarTexture(config.statusbar.texture)
GameTooltipStatusBar:SetHeight(config.statusbar.height)
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint('TOPLEFT', GameTooltip, 'BOTTOMLEFT', 2, 2)
GameTooltipStatusBar:SetPoint('TOPRIGHT', GameTooltip, 'BOTTOMRIGHT', -2, 2)

-- Default tooltip position
function module:defaultPosition(parent)
	self:SetOwner(parent, 'ANCHOR_NONE')
	self:SetPoint(unpack(config.position))
end
hooksecurefunc('GameTooltip_SetDefaultAnchor', module.defaultPosition)

-- Item Icon
if config.itemIcon then
	local itemTooltipIcon = CreateFrame('Frame', 'ItemRefTooltipIcon', ItemRefTooltip)
	itemTooltipIcon:SetPoint('TOPRIGHT', ItemRefTooltip, 'TOPLEFT', -2, -5)
	itemTooltipIcon:SetHeight(30)
	itemTooltipIcon:SetWidth(30)
	db.API:cleanBackdrop(itemTooltipIcon)

	itemTooltipIcon.texture = itemTooltipIcon:CreateTexture('ItemRefTooltipIcon', 'TOOLTIP')
	itemTooltipIcon.texture:SetAllPoints(itemTooltipIcon)
	itemTooltipIcon.texture:SetTexCoord(.08, .92, .08, .92)

	function module:addItemIcon()
		local frame = _G['ItemRefTooltipIcon']
		frame:Hide()

		local _, link = ItemRefTooltip:GetItem()
		local icon = link and GetItemIcon(link)
		if not icon then return end

		frame.texture:SetTexture(icon)
		frame:Show()
	end
	hooksecurefunc('SetItemRef', module.addItemIcon)
end

-- Setup the unit tooltip
function module:setUnit()
	local lines = self:NumLines()
	local name, unit = self:GetUnit()

	if not unit then return end

	local guild				= GetGuildInfo(unit)
	local race				= UnitRace(unit)
	local level				= UnitLevel(unit)
	local classification	= UnitClassification(unit)
	local creatureType		= UnitCreatureType(unit)
	local levelColor		= GetQuestDifficultyColor(level)

	if level == -1 then
		level = '??'
		levelColor = {
			r = 1,
			g = 0,
			b = 0
		}
	end


	for i,v in pairs(db.config.modules.unitFrames.classifications) do
		if classification == i then
			classification = v
			break
		end
	end

	-- Just set the first line to the name, no title
	if not config.showUnitTitle then
		GameTooltipTextLeft1:SetText(name)
	end

	if UnitIsPlayer(unit) then
		if guild then
			GameTooltipTextLeft2:SetFormattedText('<%s>', guild)
			GameTooltipTextLeft3:SetFormattedText('|cff%s%s|r %s', db.API:RGBToHex(levelColor), level, race)
		else
			GameTooltipTextLeft2:SetFormattedText('|cff%s%s|r %s', db.API:RGBToHex(levelColor), level, race)
		end
	else
		for i = 2, lines do
			local line = _G['GameTooltipTextLeft'..i]
			if not line or not line:GetText() then return end
			if (level and line:GetText():find('^'..LEVEL)) or (creatureType and line:GetText():find('^'..creatureType)) then
				line:SetFormattedText('|cff%s%s%s|r %s', db.API:RGBToHex(levelColor), level, classification, creatureType or 'Unknown')
				break
			end
		end
	end

	-- ToT line
	if config.showToT and UnitExists(unit..'target') then
		local r, g, b = GameTooltip_UnitColor(unit..'target')
		GameTooltip:AddLine(UnitName(unit..'target'), r, g, b)
	end
end

GameTooltip:HookScript('OnTooltipSetUnit', module.setUnit)

-- Replace the GameTooltip unit class colors function with our own
function GameTooltip_UnitColor(unitToken)
	return db.API:unitColor(unitToken)
end

db.modules.tooltip = module
