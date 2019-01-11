local db = select(2, ...)

-- Media configuration
local media = {
	flat		= [[Interface\BUTTONS\WHITE8X8]],
	gradient	= [[Interface\AddOns\@cleanUI\libraries\sharedMedia\gradient]],
	shading		= {0.1, 0.1, 0.1},
	fonts = {
		futura	= [[Fonts\arialn.ttf]],
		impact	= [[Fonts\skurri.ttf]],
	},
	unitColors = {
		offline		= {0.6, 0.6, 0.6},
		tapped		= {0.6, 0.6, 0.6},
		class		= {},
		reaction	= {},
		power = {
			['MANA']	= {0.0, 0.4, 0.6},
			['RAGE']	= {0.8, 0.2, 0.2},
			['ENERGY']	= {1.0, 1.0, 1.0},
			['FOCUS']	= {0.84, 0.41, 0.21},
		},
	},
}

-- Interface configuration
db.config = {
	modules = {
		actionBars = {
			position = {'BOTTOM', 0, 20},
		},
		actionButtons = {
			count = {
				position = {'TOPRIGHT', 2, 0},
				font = {media.fonts.impact, 11, 'OUTLINE'},
			},
			usableColors = {
				noMana = {0.4, 0.4, 0.4},
				outOfRange = {0.8, 0.1, 0.1},
			},
		},
		automation = {
			autoRepair = {
				enabled = true,
				useGuildFunds = true,
			},
			autoRestock = {
				enabled = (UnitLevel('player') == 85),
				hotDogBuns = true,  -- Should the addon try and restock to full even if it has to buy more than enough (ie you can only buy 5 stacks, but only need 3 of the item)
				ROGUE = {
					{3775,	20},    -- Crippling Poison
					{2892,	20},    -- Deadly Poison IX
					{6947,	20},    -- Instant Poison IX
					{5237,	20},    -- Mind-numbing Poison
					{10918,	20},    -- Wound Poison VII
				},
				MAGE = {
					{17020,	200},   -- Arcane Powder
					{17032,	20},    -- Rune of Portals
					{17031,	20},    -- Rune of Teleportation
				},
				DRUID = {
					{44614,	20},    -- Starleaf Seed
				},
				SHAMMAN = {
					{17030, 20},    -- Ankhs
				}
			},
			autoGreedDE = true,
			autoSellJunk = true,
			autoBGRelease = true,
			autoAcceptInvite = true,
			errorFilter = true,
		},
		buffs = {
			count = {
				position = {'TOPRIGHT', 2, 0},
				font = {media.fonts.impact, 11, 'OUTLINE'},
			},
			duration = {
				position = {'BOTTOM'},
				font = {media.fonts.impact, 11, 'OUTLINE'},
			},
			position = {'TOPRIGHT', UIParent, 'TOPRIGHT', -22, -22},
		},
		chat = {
			font = {media.fonts.futura, 13, 'OUTLINE'},
			hideButtons = true,
			hideTextures = true,
			mouseScroll = true,
			useAltKey = false,
			BNetNameMods = true,
			BNetNonWoWColor = 'bce1e0',
			resetDelay = 30,
			stickyChannels = {
				WHISPER = 1,
				CHANNEL = 1,
				OFFICER = 1,
			}
		},
		cooldowns = {
			minDuration = 3,
			position = {'BOTTOM'},
			font = {media.fonts.impact, 11, 'OUTLINE'},
		},
		experience = {
			texture = media.gradient,
			height = 8,
			color = {.2, .8, 1},
			font = {media.fonts.impact, 11, 'OUTLINE'},
			showDelay = 6,
		},
		map = {
			scale = 0.75,
		},
		minimap = {
			position = {'TOPLEFT', UIParent, 22, -22},
			clock = {
				position = {'BOTTOMRIGHT', Minimap, 0, 3},
				font = {media.fonts.impact, 11, 'OUTLINE'},
			},
			mail = {
				position = {'BOTTOMLEFT', Minimap, -2, -4},
			},
			pvp = {
				position = {'TOPRIGHT', Minimap, 2, 2},
				scale = .8,
			},
			lfg = {
				position = {'TOPRIGHT', Minimap, 2, 2},
				scale = .8,
			},
		},
		tooltip = {
			texture = media.gradient,
			shading = media.shading,
			scale = 1,
			position = {'BOTTOMRIGHT', -20, 295},
			statusbar = {
				texture = media.gradient,
				height = 3,
			},
			itemIcon = true,
			showUnitTitle = false,
			showToT = true,
		},
		nameplates = {
			texture = media.gradient,
			shading = media.shading,
			font = {media.fonts.impact, 9, 'OUTLINE'},
			unitColor = media.unitColors,
		},
		unitFrames = {
			texture = media.gradient,
			font    = media.fonts.impact,

			classifications = {
				rareelite = 'R+',
				elite = '+',
				rare = 'R',
				normal = '',
				trivial = '',
				worldboss = '',
			},

			auras = {
				total = 30,
				nonPlayerTargetDebuffs = {
					ROGUE = {
						58567, -- Sunder Armor
						64382, -- Shattering Throw
					},
				},
			},

			units = {
				{
					type = 'unit',
					unitID = 'player',
					position = {'CENTER', -250, -220},
					size = {314, 18},
				},
				{
					type = 'unit',
					unitID = 'target',
					position = {'CENTER', 250, -220},
					size = {314, 18},
				},
				{
					type = 'unit',
					unitID = 'targettarget',
					position = {'CENTER', 0, -220},
					size = {170, 10},
				},
				{
					type = 'unit',
					unitID = 'focus',
					position = {'LEFT', 20, -220},
					size = {250, 12},
				},

			}
		},
		bags = {

		},
		tracker = {

		},
	},
	API = {
		cleanBackdrop = {
			texture = media.gradient,
			shading = media.shading,
		},
		unitColor = media.unitColors,
		reverseLocalizedClasses = { },
		colorGradient = {
			1, 0, 0,
			1, 1, 0,
			0, 1, 0,
			0, 0, 0
		},
	},
	playerClass = select(2, UnitClass('player')),
	maxLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()],
}

-- Populate the reverse localized classes
for eClass, class in next, LOCALIZED_CLASS_NAMES_MALE do
	db.config.API.reverseLocalizedClasses[class] = eClass
end

for eClass, class in next, LOCALIZED_CLASS_NAMES_FEMALE do
	db.config.API.reverseLocalizedClasses[class] = eClass
end

-- Populate class, reaction, and power colors
for eclass, color in next, RAID_CLASS_COLORS do
	if not media.unitColors.class[eclass] then
		media.unitColors.class[eclass] = {color.r, color.g, color.b}
	end
end

for eclass, color in next, FACTION_BAR_COLORS do
	if not media.unitColors.reaction[eclass] then
		media.unitColors.reaction[eclass] = {color.r, color.g, color.b}
	end
end

for power, color in next, PowerBarColor do
	if type(power) == 'string' and not media.unitColors.power[power] then
		media.unitColors.power[power] = {color.r, color.g, color.b}
	end
end

-- Setup a metatable for power since blizzard
-- has so many power-types that dont seem to exist in PowerBarColor
-- This will always return the color for fuel for unknown power types
setmetatable(media.unitColors.power, {
	__index = function() return media.unitColors.power['FUEL'] end,
})

-- Set a metatable for the factions, default to grey if the token is invalid
setmetatable(media.unitColors.reaction, {
	__index = function() return media.unitColors.tapped end,
})
