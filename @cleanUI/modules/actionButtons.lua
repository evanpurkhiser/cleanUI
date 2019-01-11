local db = select(2, ...)
local config = db.config.modules.actionButtons
local module = {}

function module:styleUpdate()
	local Name = self:GetName()

	local Button	= _G[Name]
	local BtName	= _G[Name..'Name']
	local Icon		= _G[Name..'Icon']
	local Count		= _G[Name..'Count']
	local HotKey	= _G[Name..'HotKey']
	local Border 	= _G[Name..'Border']
	local Flash 	= _G[Name..'Flash']

	if not Button:GetBackdrop() then
		db.API:cleanBackdrop(Button)
		Button:SetSize(26, 26)

		-- Always show the grid
		Button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(Button)

		-- Setup the icon
		Icon:SetTexCoord(.08, .92, .08, .92)
		Icon:SetDrawLayer('ARTWORK')
	end

	-- Set the Count to a nicer font
	Count:ClearAllPoints()
	Count:SetPoint(unpack(config.count.position))
	Count:SetFont(unpack(config.count.font))

	-- Remove any text
	HotKey:Hide()
	HotKey.Show = db.API.noop
	BtName:Hide()
	BtName.Show = db.API.noop

	-- Remove the normal texture
	Flash:SetTexture('')
	Button:SetNormalTexture('')
	Button:SetCheckedTexture('')
	Button:SetHighlightTexture('')
	Button:SetPushedTexture('')
	Border:Hide()
end

-- Change the look of the button based on certian conditions
function module:usable()
	local name = self:GetName()
	local action = self.action
	local icon = _G[name..'Icon']

	local isUsable, notEnoughMana = IsUsableAction(action)
	if ActionHasRange(action) and IsActionInRange(action) == 0 then
		icon:SetVertexColor(unpack(config.usableColors.outOfRange))
		return
	elseif notEnoughMana then
		icon:SetVertexColor(unpack(config.usableColors.noMana))
		return
	elseif isUsable then
		icon:SetVertexColor(1.0, 1.0, 1.0)
		return
	else
		icon:SetVertexColor(.4, .4, .4)
		return
	end
end

-- Hook the blizzard functions
hooksecurefunc('ActionButton_Update',        module.styleUpdate)
hooksecurefunc('ActionButton_UpdateHotkeys', module.styleUpdate)
hooksecurefunc('ActionButton_OnUpdate',      module.usable)
hooksecurefunc('ActionButton_UpdateUsable',  module.usable)

db.modules.actionButtons = module
