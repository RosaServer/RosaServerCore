---@type Plugin
local plugin = ...
plugin.name = 'Admin'
plugin.author = 'jdb'
plugin.description = 'Useful commands for server administrators, with logs.'

plugin.defaultConfig = {
	-- Logs admin actions in Discord rich embeds.
	webhookEnabled = false,
	webhookHost = 'https://discord.com',
	webhookPath = '/api/webhooks/xxxxxx/xxxxxx'
}

plugin:require('manipulation')
plugin:require('moderators')
plugin:require('persistence')
plugin:require('punishment')
plugin:require('spawning')
plugin:require('teleportation')
plugin:require('utility')
plugin:require('warnings')

---Log an admin action and keep a permanent record of it.
---@param format string The string or string format to log.
---@vararg any The additional arguments passed to string.format(format, ...)
function adminLog (format, ...)
	if not plugin.isEnabled then return end

	local str = string.format(format, ...)
	plugin:print(str)
	chat.tellAdminsWrap('[Admin] ' .. str)

	local logFile = io.open('admin-log.txt', 'a')
	logFile:write('[' .. os.date("!%c") .. '] ' .. str .. '\n')
	logFile:close()
end

plugin.commands['/resetlua'] = {
	info = 'Reset the Lua state and the game.',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	call = function (ply)
		flagStateForReset(hook.persistentMode)
		adminLog('%s reset the Lua state', ply.name)
	end
}

plugin.commands['/mode'] = {
	info = 'Change the enabled mode.',
	usage = '<mode>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param args string[]
	autoComplete = function (args)
		if #args < 1 then return end

		local foundName = hook.autoCompletePlugin(args[1], 'modes')
		if foundName then
			args[1] = foundName
		end
	end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local foundPlugin = hook.getPluginByName(args[1], 'modes')
		assert(foundPlugin, 'Invalid mode')

		-- Disable all mode plugins
		for _, plug in pairs(hook.plugins) do
			if plug.nameSpace == 'modes' then
				plug:disable()
			end
		end

		-- If we reset in the middle of chat messages being parsed, things will break
		hook.once('Logic', function ()
			-- Enable the new mode
			foundPlugin:enable()

			hook.persistentMode = args[1]
		end)

		adminLog('%s set the mode to %s', ply.name, args[1])
	end
}

plugin.commands['/resetgame'] = {
	info = 'Reset the game.',
	alias = {'/rg'},
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	call = function (ply)
		-- If we reset in the middle of chat messages being parsed, things will break
		hook.once('Logic', function ()
			server:reset()
		end)

		adminLog('%s reset the game', ply.name)
	end
}