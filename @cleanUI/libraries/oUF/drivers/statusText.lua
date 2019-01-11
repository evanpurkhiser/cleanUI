local db = select(2, ...)
local oUF = db.libraries.oUF

local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsAFK = UnitIsAFK

local Update = function(self, event, unit)
	if self.unit ~= unit then return end

	local disconnect = not UnitIsConnected(unit)
	local dead  = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local afk   = UnitIsAFK(unit)

	-- Check for a status
	if disconnect or dead or ghost or afk then
		self.statusText.status = true
		self.statusText:setStatus(disconnect, dead, ghost, afk)
	elseif self.statusText.status then
		self.statusText.status = false
		self.statusText:reset(self, event, unit)
	end
end

local Enable = function(self)
	if not self.statusText then return end

	self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
	self:RegisterEvent("PARTY_MEMBER_ENABLE", Update)
	self:RegisterEvent("PARTY_MEMBER_DISABLE", Update)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)
	self:RegisterEvent("PLAYER_DEAD", Update)
	self:RegisterEvent("PLAYER_ALIVE", Update)
	self:RegisterEvent("PLAYER_UNGHOST", Update)

	return true
end

local Disable = function(self)
	if not self.statusText then return end

	self:UnRegisterEvent("PLAYER_FLAGS_CHANGED", Update)
	self:UnRegisterEvent("PARTY_MEMBER_ENABLE", Update)
	self:UnRegisterEvent("PARTY_MEMBER_DISABLE", Update)
	self:UnRegisterEvent("PARTY_MEMBERS_CHANGED", Update)
	self:UnRegisterEvent("PLAYER_DEAD", Update)
	self:UnRegisterEvent("PLAYER_ALIVE", Update)
	self:UnRegisterEvent("PLAYER_UNGHOST", Update)
end

oUF:AddElement('StatusText', Update, Enable, Disable)
