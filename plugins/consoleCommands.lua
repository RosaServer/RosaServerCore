---@type Plugin
local plugin = ...
plugin.name = 'Console Commands'
plugin.author = 'jdb'
plugin.description = 'Adds some useful console commands.'

plugin.defaultConfig = {
	announceGameModeReload = false
}

plugin.commands['clear'] = {
	info = 'Clear the terminal window.',
	call = function ()
		print('\x1bc')
	end
}

plugin.commands['eval'] = {
	info = 'Evaluate a Lua string.',
	usage = '[code]',
	---@param args string[]
	call = function (args)
		local str = table.concat(args, ' ')
		local f = assert(loadstring(str))

		f()
	end
}

plugin.commands['list'] = {
	info = 'List all current players.',
	call = function ()
		local rows = {
			{ 'Phone', 'Name' }
		}
		for _, ply in pairs(players.getNonBots()) do
			table.insert(rows, {
				dashPhoneNumber(ply.phoneNumber),
				ply.name
			})
		end
		drawTable(rows)
	end
}

plugin.commands['listplugins'] = {
	info = 'List all plugins.',
	call = function ()
		local reset = '\x1b[0m'
		local red = '\x1b[31m'
		local green = '\x1b[32m'
		local line = ('-'):rep(16)

		print(line)
		local totalHooks = 0
		local totalCommands = 0
		for _, plug in pairs(hook.plugins) do
			if plug.nameSpace == 'plugins' then
				local numHooks = table.numElements(plug.hooks)
				local numCommands = table.numElements(plug.commands)

				if plug.isEnabled then
					totalHooks = totalHooks + numHooks
					totalCommands = totalCommands + numCommands
				end

				print((plug.isEnabled and green or red) .. plug.name .. reset .. ' by ' .. plug.author)
				print('  ' .. plug.description)
				print('  Hooks:      ' .. numHooks)
				print('  Commands:   ' .. numCommands)
				print(line)
			end
		end
		print(string.format('Total of %i hooks, %i commands enabled', totalHooks, totalCommands))
	end
}

---@param args string[]
local function autoCompletePluginArg (args)
	if #args < 1 then return end

	local foundName = hook.autoCompletePlugin(args[1], 'plugins')
	if foundName then
		args[1] = foundName
	end
end

---@param args string[]
local function autoCompletePluginOrModeArg (args)
	if #args < 1 then return end

	local foundName = hook.autoCompletePlugin(args[1])
	if foundName then
		args[1] = foundName
	end
end

plugin.commands['enableplugin'] = {
	info = 'Enable a plugin.',
	usage = '<plugin>',
	autoComplete = autoCompletePluginArg,
	---@param args string[]
	call = function (args)
		assert(#args >= 1, 'usage')

		local foundPlugin = hook.getPluginByName(args[1], 'plugins')
		assert(foundPlugin, 'Invalid plugin')
		assert(not foundPlugin.isEnabled, 'Plugin already enabled')

		foundPlugin:enable(true)
		plugin:print(string.format('Enabled the %s plugin by %s', foundPlugin.name, foundPlugin.author))
	end
}

plugin.commands['disableplugin'] = {
	info = 'Disable a plugin.',
	usage = '<plugin>',
	autoComplete = autoCompletePluginArg,
	---@param args string[]
	call = function (args)
		assert(#args >= 1, 'usage')

		local foundPlugin = hook.getPluginByName(args[1], 'plugins')
		assert(foundPlugin, 'Invalid plugin')
		assert(foundPlugin ~= plugin, 'Cannot disable myself')
		assert(foundPlugin.isEnabled, 'Plugin already disabled')

		foundPlugin:disable(true)
		plugin:print(string.format('Disabled the %s plugin by %s', foundPlugin.name, foundPlugin.author))
	end
}

plugin.commands['reloadplugin'] = {
	info = 'Reload a plugin.',
	usage = '<plugin>',
	autoComplete = autoCompletePluginOrModeArg,
	---@param args string[]
	call = function (args)
		assert(#args >= 1, 'usage')

		local foundPlugin = hook.getPluginByName(args[1])
		assert(foundPlugin, 'Invalid plugin')

		local isActiveMode = foundPlugin.nameSpace == 'modes' and foundPlugin.isEnabled

		plugin:print(string.format('Reloading the %s plugin by %s', foundPlugin.name, foundPlugin.author))

		local announceGameModeReload = plugin.config.announceGameModeReload

		local startTime
		if isActiveMode then
			if announceGameModeReload then
				chat.announce('[!] Reloading the active game mode!')
				startTime = os.realClock()
			end

			foundPlugin:reload()

			if announceGameModeReload then
				local elapsed = (os.realClock() - startTime) * 1000
				chat.announce(('[!] OK (%ims)'):format(elapsed))
			end
		else
			foundPlugin:reload()
		end
	end
}

plugin.commands['watchplugin'] = {
	info = "Toggle auto-reloading for a plugin when it's modified.",
	usage = '<plugin>',
	autoComplete = autoCompletePluginOrModeArg,
	---@param args string[]
	call = function (args)
		assert(#args >= 1, 'usage')

		local foundPlugin = hook.getPluginByName(args[1])
		assert(foundPlugin, 'Invalid plugin')

		foundPlugin.doAutoReload = not foundPlugin.doAutoReload
		plugin:print(string.format(
			'%s watching the %s plugin by %s',
			foundPlugin.doAutoReload and 'Now' or 'No longer',
			foundPlugin.name,
			foundPlugin.author
		))
	end
}

plugin.commands['discoverplugins'] = {
	info = "Discover and load any plugins that weren't present at startup.",
	call = function ()
		if discoverNewPlugins() == 0 then
			plugin:print('No new plugins discovered')
		end
	end
}

plugin.commands['reloadconfig'] = {
	info = 'Reload the configuration file.',
	call = function ()
		plugin:print('Reloading configuration')
		loadConfig()
	end
}

plugin.commands['listbans'] = {
	info = 'List all current bans.',
	call = function ()
		local rows = {
			{ 'Phone', 'Time Remaining', 'Name' }
		}
		for _, acc in pairs(accounts.getAll()) do
			if acc.banTime ~= 0 then
				table.insert(rows, {
					dashPhoneNumber(acc.phoneNumber),
					acc.banTime .. 'm',
					acc.name
				})
			end
		end
		drawTable(rows)
	end
}

plugin.commands['listitemtypes'] = {
	info = 'List all item types.',
	call = function ()
		local rows = {
			{ 'Index', 'Hands', 'Price', 'Mass', 'Name' }
		}
		for _, type in pairs(itemTypes.getAll()) do
			table.insert(rows, {
				type.index,
				type.numHands,
				'$' .. commaNumber(type.price),
				commaNumber(type.mass) .. 'kg',
				type.name
			})
		end
		drawTable(rows)
	end
}

plugin.commands['listvehicletypes'] = {
	info = 'List all vehicle types.',
	call = function ()
		local rows = {
			{ 'Index', 'Price', 'Mass', 'Name' }
		}
		for _, type in pairs(vehicleTypes.getAll()) do
			table.insert(rows, {
				type.index,
				'$' .. commaNumber(type.price),
				commaNumber(type.mass) .. 'kg',
				type.name
			})
		end
		drawTable(rows)
	end
}

plugin.commands['listitems'] = {
	info = 'List all items.',
	call = function ()
		local rows = {
			{ 'Index', 'Type' }
		}
		for _, item in pairs(items.getAll()) do
			table.insert(rows, {
				item.index,
				item.type.name
			})
		end
		drawTable(rows)
	end
}