local plugin = ...

local function moveItem(item, difference)
	item.pos:add(difference)
	item.rigidBody.pos:add(difference)
end

local function teleportHumanWithItems(man, pos)
	local oldPos = man.pos:clone()
	oldPos:mult(-1.0)
	local difference = pos:clone()
	difference:add(oldPos)

	man:teleport(pos)
	for _, item in pairs({ man.leftHandItem, man.rightHandItem }) do
		moveItem(item, difference)
	end
end

plugin.commands['/find'] = {
	info = 'Teleport to a player.',
	usage = '/find <phoneNumber/name>',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')
		assert(man, 'Not spawned in')

		local victim = findOnePlayer(table.remove(args, 1))

		local victimMan = victim.human
		assert(victimMan, 'Victim not spawned in')

		-- Forward yaw plus 180 degrees
		local yaw = victimMan.viewYaw + math.pi/2
		local distance = 3

		local pos = victimMan.pos:clone()
		pos.x = pos.x + (distance * math.cos(yaw))
		pos.z = pos.z + (distance * math.sin(yaw))

		teleportHumanWithItems(man, pos)

		adminLog('%s found %s (%s)', ply.name, victim.name, dashPhoneNumber(victim.phoneNumber))
	end
}

plugin.commands['/fetch'] = {
	info = 'Teleport a player to you.',
	usage = '/fetch <phoneNumber/name>',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')
		assert(man, 'Not spawned in')

		local victim = findOnePlayer(table.remove(args, 1))

		local victimMan = victim.human
		assert(victimMan, 'Victim not spawned in')

		-- Forward yaw
		local yaw = man.viewYaw - math.pi/2
		local distance = 3

		local pos = man.pos:clone()
		pos.x = pos.x + (distance * math.cos(yaw))
		pos.z = pos.z + (distance * math.sin(yaw))

		teleportHumanWithItems(victimMan, pos)

		adminLog('%s fetched %s (%s)', ply.name, victim.name, dashPhoneNumber(victim.phoneNumber))
	end
}

plugin.commands['/hide'] = {
	info = 'Teleport to an inaccessible room.',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(man, 'Not spawned in')

		local level = server.loadedLevel
		local pos

		if level == 'test2' then
			pos = Vector(1505, 33.1, 1315)
		else
			error('Unsupported map')
		end

		teleportHumanWithItems(man, pos)

		adminLog('%s hid', ply.name)
	end
}