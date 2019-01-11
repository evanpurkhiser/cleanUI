local db = select(2, ...)
local config = db.config.modules.minimap
local module = {}

-- Setup positioning, backdrop, and size
Minimap:SetMaskTexture([[Interface\ChatFrame\ChatFrameBackground]])
Minimap:SetPoint(unpack(config.position))
Minimap:SetParent(UIParent)
Minimap:SetWidth(120)
Minimap:SetHeight(120)
db.API:cleanBackdrop(Minimap)

-- Hide stuff we dont need
MinimapBackdrop:Hide()
MinimapCluster:Hide()
GameTimeFrame:Hide()

-- World state frame
WorldStateAlwaysUpFrame:SetPoint('LEFT', Minimap, 'RIGHT', 60, 15)

-- Move and style the GM ticket
for i = 1, TicketStatusFrameButton:GetNumRegions() do
	select(i, TicketStatusFrameButton:GetRegions()):Hide()
end
db.API:cleanBackdrop(TicketStatusFrameButton)

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint('TOPLEFT', Minimap, 'TOPRIGHT', 5, 0)

-- Move and style the Ghost Frame
for i = 1, GhostFrame:GetNumRegions() do
	select(i, GhostFrame:GetRegions()):Hide()
end
db.API:cleanBackdrop(GhostFrame)


GhostFrame:ClearAllPoints()
GhostFrame:SetPoint('TOPLEFT', Minimap, 'TOPRIGHT', 5, 0)

-- Setup the minimap clock
LoadAddOn('Blizzard_TimeManager')
TimeManagerClockTicker:ClearAllPoints()
TimeManagerClockTicker:SetPoint(unpack(config.clock.position))
TimeManagerClockTicker:SetFont(unpack(config.clock.font))
TimeManagerClockTicker: SetJustifyH('RIGHT')

TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetAllPoints(TimeManagerClockTicker)
select(1, TimeManagerClockButton:GetRegions()):Hide()

function module:fixTooltip()
	if self ~= MiniMapMailFrame then
		GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	end
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', -4, -4)
end
TimeManagerClockButton:HookScript('OnEnter', module.fixTooltip)

function module:clockOnClick(button)
	if button == 'RightButton' then
		return ToggleCalendar()
	else
		return TimeManagerClockButton_OnClick(self)
	end
end
TimeManagerClockButton:SetScript('OnClick', module.clockOnClick)

-- Setup the minimap Mail notification

MiniMapMailIcon:SetTexture('Interface\\Minimap\\TRACKING\\Mailbox')
MiniMapMailIcon:SetAllPoints(MiniMapMailFrame)
MiniMapMailIcon:SetRotation(rad(-36))
MiniMapMailBorder:Hide()

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetHeight(24)
MiniMapMailFrame:SetWidth(24)
MiniMapMailFrame:SetPoint(unpack(config.mail.position))
MiniMapMailFrame:HookScript('OnEnter', module.fixTooltip)

-- Setup the minimap PVP notofication
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint(unpack(config.pvp.position))
MiniMapBattlefieldFrame:SetScale(config.pvp.scale)
MiniMapBattlefieldFrame:HookScript('OnEnter', module.fixTooltip)
MiniMapBattlefieldBorder:Hide()

function module:dropdownOnClick()
	GameTooltip:Hide()
	DropDownList1:ClearAllPoints()
	DropDownList1:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', -4, -4)
end
MiniMapBattlefieldFrame:HookScript('OnClick', module.dropdownOnClick)

-- Setup the LFD Icon and tooltip
MiniMapLFGFrame:ClearAllPoints()
MiniMapLFGFrame:SetParent(Minimap)
MiniMapLFGFrame:SetPoint(unpack(config.lfg.position))
MiniMapLFGFrame:SetScale(config.lfg.scale)
MiniMapLFGFrameBorder:Hide()

function module:lfgTooltip()
	if GetLFGMode() == 'queued' then
		LFDSearchStatus:Hide()

		-- Setup LFG tooltip
		data, _, tank, healer, dps, _, instance, _, tankWait, healerWait, damageWait = GetLFGQueueStats()

		GameTooltip:SetOwner(self, 'ANCHOR_NONE')
		GameTooltip:ClearLines()

		if data then
			GameTooltip:AddLine('In queue for:')
			GameTooltip:AddLine(instance, 1, 1, 1)
			GameTooltip:AddLine(' ')

			local totalWait = tankWait + healerWait + damageWait
			local dpsNumber = dps > 1 and ' ('..dps..')' or ''

			GameTooltip:AddDoubleLine('Group Makeup')
			GameTooltip:AddDoubleLine('Tanking Class',				db.API:formatTime(tankWait),	tank, 	1, 0,	db.API:colorGradient(1 - (tankWait/totalWait)))
			GameTooltip:AddDoubleLine('Healing Class',				db.API:formatTime(healerWait),	healer,	1, 0,	db.API:colorGradient(1 - (healerWait/totalWait)))
			GameTooltip:AddDoubleLine('Damage Class'..dpsNumber,	db.API:formatTime(damageWait),	dps, 	1, 0,	db.API:colorGradient(1 - (damageWait/totalWait)))
		else
			GameTooltip:AddLine('Acquiring LFG Queue Statistics')
			GameTooltip:AddLine('One Moment Please')
		end
		GameTooltip:Show()
	end
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', -4, -4)
end
MiniMapLFGFrame:HookScript('OnEnter', module.lfgTooltip)
MiniMapLFGFrame:HookScript('OnClick', module.dropdownOnClick)

-- Enable mouse scrolling
function module:zoomScroll(delta)
	if delta > 0 then
		MinimapZoomIn:Click()
	elseif delta < 0 then
		MinimapZoomOut:Click()
	end
end
Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', module.zoomScroll)

-- Tracking on right click
function module:trackingOnClick(button)
	if button == 'RightButton' then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, -4, -4)
		GameTooltip:Hide()
	else
		Minimap_OnClick(self)
	end
end
Minimap:SetScript('OnMouseUp', module.trackingOnClick)

-- Memory Usage
function module:memoryTooltip()
	if InCombatLockdown() then return end

	collectgarbage('collect')
	UpdateAddOnMemoryUsage()

	local memory = {}
	local total = 0

	-- Store addon memory usage
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local mem = GetAddOnMemoryUsage(i)
			tinsert (memory, {select(2, GetAddOnInfo(i)), mem})
			total = total + mem
		end
	end

	-- Sort the addons by memory usage
	table.sort(memory, function(a, b)
		return a[2] > b[2]
	end)

	module.fixTooltip(self)
	GameTooltip:AddDoubleLine('Total Usage', db.API:formatMemory(total), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddLine(' ')
	for i = 1, #memory do
		GameTooltip:AddDoubleLine(memory[i][1], db.API:formatMemory(memory[i][2]), 1, 1, 1, db.API:colorGradient(1 - memory[i][2]/total))
	end

	GameTooltip:Show()
end
Minimap:SetScript('OnEnter', module.memoryTooltip)
Minimap:SetScript('OnLeave', function() GameTooltip:Hide() end)

db.modules.minimap = module
