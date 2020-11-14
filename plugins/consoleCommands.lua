local plugin = ...
plugin.name = 'Console Commands'
plugin.author = 'jdb'
plugin.description = 'Adds some useful console commands.'

plugin.commands['clear'] = {
	info = 'Clear the terminal window.',
	---@param args string[]
	call = function (args)
		print('\x1bc')
	end
}

plugin.commands['eval'] = {
	info = 'Evaluate a Lua string.',
	---@param args string[]
	call = function (args)
		local str = table.concat(args, ' ')
		local f = assert(loadstring(str))

		f()
	end
}

plugin.commands['list'] = {
	info = 'List all current players.',
	---@param args string[]
	call = function (args)
		print('Phone', 'Name')
		for _, ply in pairs(players.getNonBots()) do
			print(ply.phoneNumber, ply.name)
		end
	end
}

plugin.commands['listplugins'] = {
	info = 'List all plugins.',
	---@param args string[]
	call = function (args)
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
				totalHooks = totalHooks + numHooks
				totalCommands = totalCommands + numCommands

				print((plug.isEnabled and green or red) .. plug.name .. reset .. ' by ' .. plug.author)
				print('  ' .. plug.description)
				print('  Hooks:      ' .. numHooks)
				print('  Commands:   ' .. numCommands)
				print(line)
			end
		end
		print(string.format('Total of %i hooks, %i commands', totalHooks, totalCommands))
	end
}

plugin.commands['listbans'] = {
	info = 'List all current bans.',
	---@param args string[]
	call = function (args)
		print('Phone', 'Time', 'Name')
		for _, acc in pairs(accounts.getAll()) do
			if acc.banTime ~= 0 then
				print(acc.phoneNumber, acc.banTime..'m', acc.name)
			end
		end
	end
}

plugin.commands['listitemtypes'] = {
	info = 'List all item types.',
	---@param args string[]
	call = function (args)
		print('Index', 'Hands', 'Price', 'Mass', 'Name')
		for _, type in pairs(itemTypes.getAll()) do
			print(type.index, type.numHands, type.price, type.mass, type.name)
		end
	end
}

plugin.commands['listitems'] = {
	info = 'List all items.',
	---@param args string[]
	call = function (args)
		print('Index', 'Type')
		for _, item in pairs(items.getAll()) do
			print(item.index, itemTypes[item.type].name)
		end
	end
}