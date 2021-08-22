---@type Plugin
local plugin = ...

local shared = plugin:require('shared')

---@param input string
---@return ItemType?
local function getItemType(input)
	local typeID = tonumber(input)

	if typeID == nil then
		for _, itemType in pairs(itemTypes.getAll()) do
			if itemType.name:lower() == input:lower() then
				return itemType
			end
		end
	else
		return itemTypes[typeID]
	end

	return nil
end

---@param input string
---@return VehicleType?
local function getVehicleType(input)
	local typeID = tonumber(input)

	if typeID == nil then
		for _, vehicleType in pairs(vehicleTypes.getAll()) do
			if vehicleType.name:lower() == input:lower() then
				return vehicleType
			end
		end
	else
		return vehicleTypes[typeID]
	end

	return nil
end

plugin.commands['/item'] = {
	info = 'Spawn an item.',
	usage = '/item <name/id>',
	alias = {'/i'},
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')
		assert(man, 'Not spawned in')

		local input = table.concat(args, ' ')
		local itemType = getItemType(input)
		assert(itemType, 'Invalid item type')

		local pos = man.pos:clone()
		pos.x = pos.x + (2 * math.cos(man.viewYaw - math.pi/2))
		pos.y = pos.y + 0.2
		pos.z = pos.z + (2 * math.sin(man.viewYaw - math.pi/2))

		if items.create(itemType, pos, orientations.e) then
			adminLog('%s spawned %s (%i)', ply.name, itemType.name, itemType.index)
		end
	end
}

plugin.commands['/delitem'] = {
	info = 'Delete items around you of a certain type.',
	usage = '/delitem <name/id>',
	alias = {'/di'},
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')
		assert(man, 'Not spawned in')

		local input = table.concat(args, ' ')
		local itemType = getItemType(input)
		assert(itemType, 'Invalid item type')

		local distance = 10

		local pos = man.pos

		local numRemoved = 0
		for _, item in pairs(items.getAll()) do
			if item.type == itemType and item.pos:distSquare(pos) <= distance*distance then
				item:remove()
				numRemoved = numRemoved + 1
			end
		end

		if numRemoved > 0 then
			adminLog('%s deleted %i %s (%i)', ply.name, numRemoved, itemType.name, itemType.index)
		end
	end
}

plugin.commands['/car'] = {
	info = 'Spawn a vehicle.',
	usage = '/car [name/id] [color]',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(man, 'Not spawned in')

		local vehicleType = getVehicleType(args[1] or 'Town Car')
		assert(vehicleType, 'Invalid vehicle type')

		local color = math.floor(args[2] or 1)

		local yaw = man.viewYaw - math.pi/2

		local pos = man.pos:clone()
		pos.x = pos.x + (4 * math.cos(yaw))
		pos.y = pos.y + 0.5
		pos.z = pos.z + (4 * math.sin(yaw))

		local car = vehicles.create(vehicleType, pos, yawToRotMatrix(man.viewYaw), color)
		if car then
			man.vehicle = car
			man.vehicleSeat = 0
			adminLog('%s spawned vehicle %s (%i)', ply.name, vehicleType.name, vehicleType.index)
		end
	end
}

plugin.commands['/heli'] = {
	info = 'Spawn a helicopter.',
	usage = '/heli [color]',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		plugin.commands['/car'].call(ply, man, { 'Helicopter', args[1] or nil })
	end
}

plugin.commands['/bot'] = {
	info = 'Spawn a Megacorp bot.',
	usage = '/bot [team]',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(man, 'Not spawned in')

		local pos = man.pos:clone()
		pos.x = pos.x + (2 * math.cos(man.viewYaw - math.pi/2))
		pos.y = pos.y + 0.2
		pos.z = pos.z + (2 * math.sin(man.viewYaw - math.pi/2))

		local team = tonumber(args[1] or 6)

		local bot = players.createBot()
		if bot ~= nil then
			bot.name = ''
			bot.team = team
			bot.gender = 1
			bot.skinColor = 0
			bot.hairColor = 0
			bot.hair = 0
			bot.eyeColor = 0
			bot.head = 0
			bot.suitColor = 1
			bot.tieColor = 0
			bot.model = 1
			bot:update()
			local botMan = humans.create(pos, RotMatrix(1, 0, 0, 0, 1, 0, 0, 0, 1), bot)
			if not botMan then
				bot:remove()
				error('Could not create bot')
			end
			botMan:arm(7, 3)

			adminLog('%s created a bot, team %i', ply.name, team)
		end
	end
}

plugin.commands['/cash'] = {
	info = 'Give yourself money.',
	usage = '/cash [amount]',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		local amount = math.floor(args[1] or 100000)
		ply.money = ply.money + amount
		ply:updateFinance()

		adminLog('%s gave themself $%i', ply.name, amount)
	end
}

plugin.commands['/give'] = {
	info = 'Give a player money.',
	usage = '/give <phoneNumber> <amount>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 2, 'usage')

		local amount = assert(tonumber(args[2]), 'Amount is not a number')
		amount = math.floor(amount)
		if amount < 1 then error('Invalid amount') end

		local phoneNumber = assert(undashPhoneNumber(args[1]), 'Invalid phone number')

		local victim = players.getByPhone(phoneNumber)
		if victim and not victim.isBot then
			victim.money = victim.money + amount
			victim:updateFinance()
			adminLog('%s gave $%i to %s (%s)', ply.name, amount, victim.name, dashPhoneNumber(victim.phoneNumber))
		else
			local acc = assert(accounts.getByPhone(phoneNumber), 'Phone number does not exist')
			if acc then
				acc.money = acc.money + amount
				adminLog('%s gave $%i to %s (%s) (Offline)', ply.name, amount, acc.name, dashPhoneNumber(acc.phoneNumber))
			end
		end
	end
}

plugin.commands['/botply'] = {
	info = 'Create bot players. Does nothing in default gamemodes.',
	usage = '/botply [amount] [team]',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		local numBots = tonumber(args[1] or 1)
		local team = tonumber(args[2] or 7)

		for _ = 1, numBots do
			local bot = players.createBot()
			if bot then
				-- Everything else is already randomized
				bot.gender = math.random(0, 1)
				bot.name = 'Bot'
				bot.isReady = true
				bot.team = team
				bot:update()
			end
		end

		adminLog('%s created %i bot player%s, team %i', ply.name, numBots, numBots == 1 and '' or 's', team)
	end
}

plugin.commands['/del'] = {
	info = "Delete an object you're looking at.",
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	call = function (ply, man)
		assert(man, 'Not spawned in')
		local dist = 64

		local yaw = man.viewYaw - math.pi/2
		local pitch = -man.viewPitch

		local pos = man:getRigidBody(3).pos
		local pos2 = Vector(
			pos.x + (dist * math.cos(yaw) * math.cos(pitch)),
			pos.y + (dist * math.sin(pitch)),
			pos.z + (dist * math.sin(yaw) * math.cos(pitch))
		)

		local hitRays = {}

		local ray = physics.lineIntersectLevel(pos, pos2)
		if ray.hit then
			table.insert(hitRays, ray)
		end

		for _, human in pairs(humans.getAll()) do
			if human.index ~= man.index then
				ray = physics.lineIntersectHuman(human, pos, pos2)
				if ray.hit then
					ray.obj = human
					ray.type = 'human'
					table.insert(hitRays, ray)
				end
			end
		end

		for _, vcl in pairs(vehicles.getAll()) do
			ray = physics.lineIntersectVehicle(vcl, pos, pos2)
			if ray.hit then
				ray.obj = vcl
				ray.type = 'vehicle'
				table.insert(hitRays, ray)
			end
		end

		table.sort(hitRays, function(a, b)
			return a.fraction < b.fraction
		end)

		if #hitRays > 0 then
			ray = hitRays[1]
			if ray.obj then
				ray.obj:remove()
				adminLog('%s deleted a %s', ply.name, ray.type)
			end
			events.createBulletHit(2, ray.pos, ray.normal)
		end
	end
}