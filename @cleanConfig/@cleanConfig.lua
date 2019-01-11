local function SimplueUIConfig()
	-- Setup Basic InGame settings
	SetCVar("buffDurations", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("consolidateBuffs", 0)
	SetCVar("ffxDeath", 0)
	SetCVar("chatMouseScroll", 1)

	-- Position and size the frame
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT",UIParent, 20, 20)
	ChatFrame1:SetWidth(450)
	ChatFrame1:SetHeight(118)
	FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, 1)

	local channels = {
		"SAY",
		"EMOTE",
		"YELL",
		"GUILD",
		"GUILD_OFFICER",
		"GUILD_ACHIEVEMENT",
		"ACHIEVEMENT",
		"WHISPER",
		"PARTY",
		"RAID",
		"RAID_LEADER",
		"RAID_WARNING",
		"BATTLEGROUND",
		"BATTLEGROUND_LEADER",
		"CHANNEL1",
		"CHANNEL2",
	}

	for i, v in ipairs(channels) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	if IsAddOnLoaded("MikScrollingBattleText") then
		-- Setup MSBT
		MikSBT.Profiles.savedVariables.profiles["Clean"] = {
			["normalOutlineIndex"] = 2,
			["exclusiveSkillsDisabled"] = true,
			["glancing"] = {
				["disabled"] = true,
			},
			["crushing"] = {
				["disabled"] = true,
			},
			["hideFullOverheals"] = true,
			["hideSkills"] = true,
			["regenAbilitiesDisabled"] = true,
			["triggers"] = {
				["Custom1"] = {
					["message"] = "Bloodlust!",
					["colorB"] = 0,
					["colorR"] = 0,
					["alwaysSticky"] = true,
					["scrollArea"] = "Static",
					["fontSize"] = 26,
					["mainEvents"] = "SPELL_AURA_APPLIED{recipientAffiliation;;eq;;4026531840;;skillName;;eq;;Bloodlust}",
				},
			},
			["critFontName"] = "Skurri",
			["critOutlineIndex"] = 2,
			["soundsDisabled"] = true,
			["textShadowingDisabled"] = true,
			["hideNames"] = true,
			["skillIconsDisabled"] = true,
			["events"] = {
				["NOTIFICATION_COMBAT_ENTER"] = {
					["scrollArea"] = "Static",
				},
				["NOTIFICATION_COMBAT_LEAVE"] = {
					["scrollArea"] = "Static",
				},
				["NOTIFICATION_CP_FULL"] = {
					["message"] = "5 CP - Let it Rip!",
					["scrollArea"] = "Static",
				},
				["NOTIFICATION_EXTRA_ATTACK"] = {
					["disabled"] = true,
				},
				["NOTIFICATION_CP_GAIN"] = {
					["alwaysSticky"] = true,
					["scrollArea"] = "Static",
				},
			},
			["scrollAreas"] = {
				["Notification"] = {
					["disabled"] = true,
				},
				["Static"] = {
					["critFontSize"] = 28,
					["scrollHeight"] = 200,
					["offsetY"] = -165,
					["direction"] = "Up",
					["normalFontSize"] = 20,
				},
				["Incoming"] = {
					["direction"] = "Up",
					["stickyBehavior"] = "Normal",
					["stickyTextAlignIndex"] = 2,
					["scrollWidth"] = 300,
					["offsetX"] = -406,
					["textAlignIndex"] = 1,
					["behavior"] = "MSBT_NORMAL",
					["offsetY"] = -165,
					["animationStyle"] = "Straight",
					["scrollHeight"] = 200,
				},
				["Outgoing"] = {
					["stickyTextAlignIndex"] = 2,
					["behavior"] = "MSBT_NORMAL",
					["skillIconsDisabled"] = true,
					["stickyBehavior"] = "Normal",
					["scrollHeight"] = 200,
					["offsetX"] = 106,
					["animationStyle"] = "Straight",
					["direction"] = "Up",
					["offsetY"] = -165,
					["textAlignIndex"] = 3,
					["scrollWidth"] = 300,
				},
			},
			["alwaysShowQuestItems"] = false,
			["normalFontName"] = "Skurri",
			["creationVersion"] = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION,
		}
		MikSBT.Profiles.SelectProfile("Clean")
	end

	-- Ask if they want to reload the UI
	StaticPopup_Show("RELOAD_UI")
	DisableAddOn("@cleanConfig")
end

-- Create confirmation popup
StaticPopupDialogs["CONFIGURE_UI"] = {
	text = "Would you like to configure CleanUI now?",
	button1 = YES,
	button2 = NO,
	OnAccept = SimplueUIConfig,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
	exclusive = true
}

-- Create reload confirmation popup
StaticPopupDialogs["RELOAD_UI"] = {
	text = "CleanUI has been sucessfully configured!\n Would you like to reload the Interface now?",
	button1 = YES,
	button2 = NO,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
	exclusive = true
}

StaticPopup_Show("CONFIGURE_UI")
