local db = select(2, ...)
local config = db.config.modules.automation
local module = {}

-- Auto repair at vendor
function module:autoRepair()
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		if cost > 0 and not IsShiftKeyDown() then
			if cost > GetMoney() then
				print('Insufficient Funds to Repair.')
				return
			end

			if CanGuildBankRepair() and config.autoRepair.useGuildFunds then
				RepairAllItems(1)
				if GetRepairAllCost() == 0 then
					print(('All items repaired using guild bank funds for %s.'):format(db.API:formatGold(cost)))
					return
				end
			end

			if GetRepairAllCost() then
				RepairAllItems()
				print(('All items repaired for %s.'):format(db.API:formatGold(cost)))
			end
		end
	end
end
db.API:RegisterEvents(config.autoRepair.enabled and module.autoRepair, 'MERCHANT_SHOW')

-- Sell junk
function module:autoSellJunk()
	for bagIndex = 0, 4 do
		if GetContainerNumSlots(bagIndex) > 0 then
			for slotIndex = 1, GetContainerNumSlots(bagIndex) do
				if select(2,GetContainerItemInfo(bagIndex, slotIndex)) then
					local quality = string.match(GetContainerItemLink(bagIndex, slotIndex), '(|c%x+)')

					if quality == ITEM_QUALITY_COLORS[0].hex then
						UseContainerItem(bagIndex, slotIndex)
					end
				end
			end
		end
	end
end
db.API:RegisterEvents(config.autoSellJunk and module.autoSellJunk, 'MERCHANT_SHOW')

-- Restock Reagents
function module:autoRestock()
	local items = config.autoRestock[db.config.playerClass]
	local index, reagent

	if not items then return end

	for index = 1, GetMerchantNumItems() do
		local vendorItem = tonumber(string.match(GetMerchantItemLink(index) or '', 'item:(%d+):'))
		for _, reagent in ipairs(items) do
			if reagent[1] == vendorItem then
				local numToBuy = reagent[2]
				local curStock = GetItemCount(vendorItem)
				local VendorStacks = select(4, GetMerchantItemInfo(index))
				local maxStack = GetMerchantItemMaxStack(index)

				numToBuy = max(0, (numToBuy - curStock) / VendorStacks)
				numToBuy = config.autoRestock.hotDogBuns and ceil(numToBuy) or floor(numToBuy)

				while numToBuy > 0 do
					local buy = numToBuy > maxStack and maxStack or numToBuy
					BuyMerchantItem(index, buy)
					numToBuy = numToBuy - buy
				end

				break
			end
		end
	end
end
db.API:RegisterEvents(config.autoRestock.enabled and module.autoRestock, 'MERCHANT_SHOW')

-- Auto release in battle grounds
function module:autoBGRelease()
	if MiniMapBattlefieldFrame.status == 'active' then
		RepopMe()
	end
end
db.API:RegisterEvents(config.autoBGRelease and module.autoBGRelease, 'PLAYER_DEAD')

-- Auto Greed / DE greens
function module:autoGreedDE(event, id)
	if id and select(4, GetLootRollItemInfo(id)) == 2 then
		RollOnLoot(id, select(8, GetLootRollItemInfo(id)) and 3 or 2)
	end
end
db.API:RegisterEvents(config.autoGreedDE and module.autoGreedDE, 'START_LOOT_ROLL')

-- Auto Accept Invites
function module:autoAcceptInvite()
	 for i=1,STATICPOPUP_NUMDIALOGS do
		local frame = _G['StaticPopup'..i]
		if frame:IsVisible() and frame.which == 'PARTY_INVITE' then StaticPopup_OnClick(frame, 1) end
	end
end
db.API:RegisterEvents(config.autoAcceptInvite and module.autoAcceptInvite, 'PARTY_INVITE_REQUEST')

-- Hide annoying error messages
if config.errorFilter then
	local originalInfoEvent = UIErrorsFrame:GetScript('OnEvent')
	UIErrorsFrame:SetScript('OnEvent', function(self, event, ...)
		if event ~= 'UI_ERROR_MESSAGE' or not InCombatLockdown() then
			originalInfoEvent(self, event, ...)
		end
	end)
end

-- Create a open all mail button on the inbox
module.openMail = CreateFrame("Button", _, InboxFrame, "UIPanelButtonTemplate")
module.openMail:SetSize(115, 26)
module.openMail:SetPoint("TOPRIGHT", -45, -42)
module.openMail:SetText("Open All Mail")
module.openMail:SetScript("OnClick", function(self)
	if GetInboxNumItems() < 1 then return end

	local timeInterval = select(3, GetNetStats()) / 200
	local total  = GetInboxNumItems()
	local update = timeInterval + 1

	self:SetScript("OnUpdate", function(self, t)
		update = update + t
		if update < timeInterval then return end
		if total  < 2 then self:SetScript("OnUpdate", nil) end

		local _, _, _, _, _, cod = GetInboxHeaderInfo(total);
		if ( cod <= 0 ) then
			AutoLootMailItem(total);
		end

		total, update = total - 1, 0
	end)
end)

MailFrame:SetScript("OnHide", function()
	module.openMail:SetScript("OnUpdate", nil)
end)

-- Usfull slash commands
db.API:setSlashCommand('ReloadUI', ReloadUI, 'rl', 'reset')
db.API:setSlashCommand('HelpUI', ToggleHelpFrame, 'gm', 'gamehelp')
db.API:setSlashCommand('ReadyCheck', DoReadyCheck, 'rc', 'rcheck')
db.API:setSlashCommand('RestartGX', function() ConsoleExec('gxRestart') end, 'gxrestart')

db.modules.automation = module
