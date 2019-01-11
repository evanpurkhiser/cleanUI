--[[
	slashCmds.lua
	A helper designed to make it easyer to set in game slash commands

	API Functions:
	 - setSlashCommand
		param  | name - A unique identifier for the slash command
		param  | func - The function to be called upon the slash command being fired
		param  | commands - (vararg) A list of the actual slash commands that can be typed
		return | none
]]--

local db = select(2, ...)
local config = db.config.API

function db.API:setSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    for i = 1, select('#', ...) do
        _G['SLASH_'..name..i] = '/'..select(i, ...)
    end
end
