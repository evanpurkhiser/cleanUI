local db = select(2, ...)
local config = db.config.modules.map
local module = {}

-- Credit goes to Cargor for this one
-- https://github.com/xconstruct/cargInterface/blob/master/map.lua

-- Scaling fixes, needed since WorldMapFrame became tainted
local _SetupFullScreenScale = SetupFullScreenScale

function SetupFullscreenScale(self)
	if(self ~= WorldMapFrame) then
		return _SetupFullscreenScale(self)
	end
end

function module:fixMap()
	BlackoutWorld:Hide()
	WorldMapFrame:EnableKeyboard(nil)
	WorldMapFrame:EnableMouse(nil)
	WorldMapFrame:SetScale(config.scale)

	UIPanelWindows["WorldMapFrame"].area = "center"
	WorldMapFrame:SetAttribute("UIPanelLayout-defined", nil)
end

hooksecurefunc("WorldMap_ToggleSizeUp", module.fixMap)
module:fixMap()

db.modules.map = module
