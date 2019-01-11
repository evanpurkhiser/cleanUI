local db = select(2, ...)
local config = db.config.modules.experience
local module = {}

-- Create a new status bar
module.bar = CreateFrame("StatusBar", _, UIParent)
module.bar:SetStatusBarTexture(config.texture)
module.bar:SetStatusBarColor(unpack(config.color))
module.bar:SetMinMaxValues(0, 1)
module.bar:SetAlpha(0)
module.bar:SetHeight(config.height)
db.API:cleanBackdrop(module.bar)

-- Position
local setPosition = function()
	local pos

	if MultiBarBottomRight:IsShown() then
		pos = 98
	elseif MultiBarBottomLeft:IsShown() then
		pos = 64
	else
		pos = 30
	end

	module.bar:SetPoint('BOTTOMLEFT', db.modules.actionBars, 'TOPLEFT', 0, pos)
	module.bar:SetPoint('BOTTOMRIGHT', db.modules.actionBars, 'TOPRIGHT', 0, pos)
end

MultiBarBottomLeft:SetScript("OnShow", setPosition)
MultiBarBottomLeft:SetScript("OnHide", setPosition)
MultiBarBottomRight:SetScript("OnShow", setPosition)
MultiBarBottomRight:SetScript("OnHide", setPosition)
setPosition()

-- Create the percentage text
module.percentage = module.bar:CreateFontString(nil, "OVERLAY")
module.percentage:SetPoint("BOTTOMLEFT", module.bar, "TOPLEFT", -2, 2)
module.percentage:SetPoint("BOTTOMRIGHT", module.bar, "TOPRIGHT", 2, 2)
module.percentage:SetFont(unpack(config.font))
module.percentage:SetJustifyH("LEFT")

-- Create the total text
module.total = module.bar:CreateFontString(nil, "OVERLAY")
module.total:SetPoint("BOTTOMLEFT", module.bar, "TOPLEFT", -2, 2)
module.total:SetPoint("BOTTOMRIGHT", module.bar, "TOPRIGHT", 2, 2)
module.total:SetFont(unpack(config.font))
module.total:SetJustifyH("RIGHT")

-- Setup a fadein / fadeout
module.animation = module.bar:CreateAnimationGroup()

module.fadeIn = module.animation:CreateAnimation("Alpha")
module.fadeIn:SetChange(1)
module.fadeIn:SetDuration(.5)
module.fadeIn:SetOrder(1)
module.fadeIn:SetSmoothing("IN_OUT")

module.fadeOut = module.animation:CreateAnimation("Alpha")
module.fadeOut:SetChange(-1)
module.fadeOut:SetDuration(.5)
module.fadeOut:SetStartDelay(config.showDelay)
module.fadeOut:SetOrder(2)
module.fadeOut:SetSmoothing("IN_OUT")

-- Update the XP
function module:updateXP()
	if UnitLevel('player') == db.config.maxLevel then return end

	local min     = UnitXP("player")
	local max     = UnitXPMax("player")
	local rested  = GetXPExhaustion()
	local percent = min / max;

	-- Set the bar percentage
	module.bar:SetValue(percent);

	-- Setup the text
	if rested and rested > 0 then
		module.percentage:SetFormattedText('%d%% (%d%% Rested)', percent * 100, rested / max * 100)
	else
		module.percentage:SetFormattedText('%d%%', percent * 100)
	end
	module.total:SetFormattedText('%s/%s', db.API:formatNumber(min), db.API:formatNumber(max))
end
db.API:RegisterEvents(module.updateXP, 'PLAYER_ENTERING_WORLD', 'PLAYER_XP_UPDATE')

-- Update the Watched reputation
function module:updateRep()
	local name, reaction, inital, final, value = GetWatchedFactionInfo();

	if UnitLevel('player') ~= db.config.maxLevel or not name then return end

	-- Get the percentage
	local min     = value - inital
	local max     = final - inital
	local percent = min / max;

	-- Set the bar percentage
	module.bar:SetValue(percent);

	-- Setup the text
	module.percentage:SetFormattedText('%d%% %s', percent * 100, name)
	module.total:SetFormattedText('%s/%s', db.API:formatNumber(min), db.API:formatNumber(max))
end
db.API:RegisterEvents(module.updateRep, 'PLAYER_ENTERING_WORLD', 'UPDATE_FACTION')

-- Save the current watched faction value
local watchedName, _, _, _, watchedValue = GetWatchedFactionInfo();

function module:showBar(event)
	if UnitLevel('player') < db.config.maxLevel then
		module.animation:Play()
	else
		local name, _, _, _, value = GetWatchedFactionInfo();
		if not name or (type(event) == 'string' and (watchedName == name and watchedValue == value)) then return end

		watchedValue = value
		watchedName = name

		module.animation:Play()
	end
end
db.API:RegisterEvents(module.showBar, 'PLAYER_XP_UPDATE', 'UPDATE_FACTION')

-- Setup a easy slash-command to show the bar
db.API:setSlashCommand("ShowXp", module.showBar, 'xp', 'rep')

db.modules.experience = module
