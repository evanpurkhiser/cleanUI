local db = select(2, ...)
local oUF = db.libraries.oUF

local Update = function(self, event, unit)

end

local Enable = function(self)

end

local Disable = function(self)

end

oUF:AddElement('StatusIcons', Update, Enable, Disable)
