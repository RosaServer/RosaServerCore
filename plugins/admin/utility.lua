---@type Plugin
local plugin = ...

plugin.commands['/message'] = {
	info = 'Announce a message.',
	usage = '/message <message>',
	alias = {'/msg'},
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local str = table.concat(args, ' ')
		chat.announceWrap(str)

		adminLog('%s announced a message: %s', ply.name, str)
	end
}

plugin.commands['/say'] = {
	info = 'Announce a message prepended by (Moderator).',
	usage = '/say <message>',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local str = table.concat(args, ' ')
		chat.announceWrap('(Moderator) ' .. str)

		adminLog('%s announced a mod message: %s', ply.name, str)
	end
}

plugin.commands['/name'] = {
	info = 'Set the server name.',
	usage = '/name <name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local str = table.concat(args, ' ')
		server.name = str

		adminLog('%s set the server name to %s', ply.name, server.name)
	end
}

plugin.commands['/time'] = {
	info = 'Set the solar time.',
	usage = '/time <hour/hour:minute>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local split = args[1]:split(':')

		local hours = math.floor(split[1]) % 24
		local minutes = 0
		if split[2] then
			minutes = math.floor(split[2]) % 60
		end

		local allMinutes = minutes + hours * 60
		local ticks = math.floor(allMinutes * server.TPS * 60)

		server.sunTime = ticks
		adminLog('%s set the time to %02d:%02d', ply.name, hours, minutes)
	end
}

plugin.commands['/posa'] = {
	info = 'Get cuboid lower coordinate.',
	canCall = function (ply) return ply.isAdmin end,
	---@param man Human?
	call = function (_, man)
		assert(man, 'Not spawned in')

		local pos = man.pos
		local str = string.format('%i, %i, %i', math.floor(pos.x), math.floor(pos.y) - 2, math.floor(pos.z))
		man:speak(str, 0)

		if postText then
			postText('Vector(' .. str .. ')')
		end
	end
}

plugin.commands['/posb'] = {
	info = 'Get cuboid upper coordinate.',
	canCall = function (ply) return ply.isAdmin end,
	---@param man Human?
	call = function (_, man)
		assert(man, 'Not spawned in')

		local pos = man.pos
		local str = string.format('%i, %i, %i', math.ceil(pos.x), math.ceil(pos.y), math.ceil(pos.z))
		man:speak(str, 0)

		if postText then
			postText('Vector(' .. str .. ')')
		end
	end
}

plugin.commands['/pos'] = {
	info = 'Get your current position.',
	canCall = function (ply) return not ply.isConsole end,
	---@param ply Player
	---@param man Human?
	call = function (ply, man)
		assert(man, 'Not spawned in')

		local pos = man.pos
		local str = string.format('%.2f, %.2f, %.2f', pos.x, pos.y, pos.z)
		ply:sendMessage(str)

		if ply.isAdmin and postText then
			postText('Vector(' .. str .. ')')
		end
	end
}

plugin.commands['/skip'] = {
	info = 'Skip the round timer.',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	call = function (ply)
		if server.time <= server.TPS then error('Too early to skip') end

		server.time = server.TPS
		adminLog('%s skipped the timer', ply.name)
	end
}

plugin.commands['/who'] = {
	info = 'Search players by name.',
	usage = '/who <name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		local name = table.concat(args, ' '):lower()
		local anyMatch = false

		for _, other in pairs(players.getNonBots()) do
			if other.name:lower():find(name) then
				ply:sendMessage(string.format('%s - %s', dashPhoneNumber(other.phoneNumber), other.name))
				anyMatch = true
			end
		end

		if not anyMatch then
			ply:sendMessage('No matches')
		end
	end
}