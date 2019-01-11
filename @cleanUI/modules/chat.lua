local db = select(2, ...)
local config = db.config.modules.chat
local module = {}

-- Hide the chatframes buttons
function module:SetupFrames(chatFrame)
	if not chatFrame then return end

	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton.Show = db.API.noop

	_G[chatFrame..'ButtonFrame']:Hide()
	_G[chatFrame..'ButtonFrame'].Show = db.API.noop

	-- Setup the edit box
	for i, v in pairs({select(6, _G[chatFrame..'EditBox']:GetRegions())}) do
		if v.GetTexture and v:GetTexture() then v:SetTexture(nil) end
	end

	_G[chatFrame..'EditBox']:HookScript('OnTextChanged', self.tellTarget)
	_G[chatFrame..'EditBox']:SetAltArrowKeyMode(config.useAltKey)

	self:setChatFont(chatFrame..'EditBox')
	self:setChatFont(chatFrame..'EditBoxHeader')

	_G[chatFrame..'EditBox']:ClearAllPoints()
	_G[chatFrame..'EditBox']:SetPoint('BOTTOMLEFT', ChatFrame1, 'TOPLEFT', -14, -2)
	_G[chatFrame..'EditBox']:SetPoint('BOTTOMRIGHT', ChatFrame1, 'TOPRIGHT', 0, -2)

	_G[chatFrame]:SetFading(false)
end

-- Hide the chatframe background texture
function module:hideChatTextures(chatFrame)
	if not chatFrame then return end

	for i, v in ipairs(CHAT_FRAME_TEXTURES) do
		_G[chatFrame..v]:SetTexture(nil)
	end
end

-- Setup the chat scroll on mousewheel
function module:setChatScroll(chatFrame)
	if not chatFrame then return end

	local function onScrollUpdate(self, interval)
		self.scrollDelay = self.scrollDelay + interval
		if self.scrollDelay > config.resetDelay then
			self:ScrollToBottom()
			self.scrollDelay = 0
			self:SetScript('OnUpdate', nil)
		end
	end

	local function onScroll(self, delta)
		if delta > 0 then
			self.scrollDelay = 0
			self:SetScript('OnUpdate', onScrollUpdate)
		elseif delta < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
				self:SetScript('OnUpdate', nil)
			else
				self.scrollDelay = 0
				if self:AtBottom() then
					self:SetScript('OnUpdate', nil)
				end
			end
		end
	end

	hooksecurefunc("FloatingChatFrame_OnMouseScroll", onScroll)
end

-- Set the chat font
function module:setChatFont(chatFrame)
	_G[chatFrame]:SetFont(unpack(config.font))
	_G[chatFrame]:SetShadowOffset(0, 0)
end

-- Hook the send message function
function module:hookAddMessage(chatFrame)
	_G[chatFrame].AddMessagePreHook = _G[chatFrame].AddMessage
	_G[chatFrame].AddMessage = self.addMessage
end

-- Hook the OnHyperlinkShow function for URL copy
function module:hookChatURL()
	self.OnHyperlinkShow = ChatFrame_OnHyperlinkShow
	ChatFrame_OnHyperlinkShow = self.chatURL
end

-- Replace the hyperlink function to check for URLs
function module:chatURL(link, ...)
	local type, url = link:match('(%a+):(.+)')
	if type == 'url' then
		local dialog = StaticPopup_Show('URL_COPY')
		local editbox = _G[dialog:GetName()..'EditBox']
		editbox:SetText(url)
		editbox:SetFocus()
		editbox:HighlightText()
		dialog:SetWidth(400)
		editbox:SetWidth(350)

	else
		module.OnHyperlinkShow(self, link, ...)
	end
end

-- Replace the add message function for each window
function module:addMessage(text, ...)
	-- Remove channel names and brackets around character names
	text = gsub(text, '^|Hchannel:[^%|]+|h%[[^%]]+%]|h ', '')
	text = gsub(text, '|Hplayer:([^%|]+)|h%[([^%]]+)%]|h', '|Hplayer:%1|h%2|h')

	-- Remove 'Says:' and 'Yells:'
	text = gsub(text, '|Hplayer:([^%|]+)|h(.+)|h says:', '|Hplayer:%1|h%2|h:')
	text = gsub(text, '|Hplayer:([^%|]+)|h(.+)|h yells:', '|Hplayer:%1|h%2|h:')

	-- Make tells use T and F instead of 'whispers:'
	text = gsub(text, '|Hplayer:([^%|]+)|h(.+)|h whispers:', 'F |Hplayer:%1|h%2|h:')
	text = gsub(text, '|HBNplayer:(.+)|h whispers:', 'F |HBNplayer:%1|h:')
	text = gsub(text, '^To', 'T')

	-- Remove Away / DND / AFK text
	text = gsub(text, '^<Away>', '')
	text = gsub(text, '^<AFK>', '')
	text = gsub(text, '^<DND>', '')

	-- Setup url links
	text = gsub(text, '([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')

	-- Bnet only features (Remove the brackets and colorize the name)
	if config.BNetNameMods and strfind(text, '|HBNplayer:(.+)|h') then
		local id = tonumber(strmatch(text, '|HBNplayer:|Kf([%d]+).*|h'))

		-- Figure out which friend it is
		for i = 1, BNGetNumFriends() do
			local presenceID, _, _, _, toonID, client, online = BNGetFriendInfo(i)

			if presenceID == id then
				local classColor = config.BNetNonWoWColor

				-- Class colors
				if client == BNET_CLIENT_WOW and online then
					local class = select(7, BNGetToonInfo(toonID))
					class = db.config.API.reverseLocalizedClasses[class]
					classColor = db.config.API.unitColor.class[class]
					classColor = db.API:RGBToHex(unpack(classColor))
				end

				-- Colorize the name
				text = gsub(text, '|HBNplayer:([^%[]+)%[([^%]]+)%]|h', '|HBNplayer:%1|cff'..classColor..'%2|r|h')

				break;
			end
		end
	else
		text = gsub(text, '|HBNplayer:([^%[]+)%[([^%]]+)%]|h', '|HBNplayer:%1%2|h')
	end

	return self:AddMessagePreHook(text, ...)
end

-- Tell Target
function module:tellTarget()
	local text = self:GetText()
	if text:len() < 5 then
		if text:sub(1, 4) == '/tt ' and  UnitName('target') then
			local unitname, realm = UnitName('target')
			unitname = gsub(unitname, ' ', '')
			ChatFrame_SendTell(unitname, ChatFrame1)
		end
	end
end

do
	-- Iterate through each chat frame
	for i = 1, NUM_CHAT_WINDOWS do
		local chatFrame = 'ChatFrame'..i

		module:SetupFrames(config.hideButtons and chatFrame)
		module:hideChatTextures(config.hideTextures and chatFrame)
		module:setChatScroll(config.mouseScroll and chatFrame)
		module:setChatFont(chatFrame)
		module:hookAddMessage(chatFrame)
	end

	-- Hide the docking frame
	GeneralDockManager:Hide()
	GeneralDockManager.Show = db.API.noop

	-- Unclamp the chatframe
	ChatFrame1:SetClampedToScreen(false)

	-- Hide the freinds button
	FriendsMicroButton:Hide()
	FriendsMicroButton.Show = db.API.noop

	-- Setup each sticky channel
	for i, v in pairs(config.stickyChannels) do
		ChatTypeInfo[i].sticky = v
	end

	-- Setup URL Copy
	module:hookChatURL()
	StaticPopupDialogs['URL_COPY'] = {
		text = 'URL Copy',
		hasEditBox = true,
		timeout = 0,
		hideOnEscape = 1,

		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
	}
end

db.modules.chat = module
