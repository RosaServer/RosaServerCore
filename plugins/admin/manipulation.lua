---@type Plugin
local plugin = ...
local module = {}

local flyingMachines
local disablePhys
local disableBul

function module.onEnable ()
	flyingMachines = {}
	disablePhys = false
	disableBul = false
end

function module.onDisable ()
	for id, vcl in pairs(flyingMachines) do
		local man = humans[id]
		if isActive(vcl) then
			vcl:remove()
			if isActive(man) then
				man.vehicle = nil
			end
		end
	end

	flyingMachines = nil
	disablePhys = nil
	disableBul = nil
end

function plugin.hooks.Physics ()
	if disablePhys then
		return hook.override
	end

	for id, vcl in pairs(flyingMachines) do
		local man = humans[id]
		if not isActive(man) or not isActive(man.player) or not isActive(vcl) or not man.vehicle then
			if isActive(vcl) then
				vcl:remove()
				if isActive(man) then
					man.vehicle = nil
				end
			end
			flyingMachines[id] = nil
		else
			local s = 0.1
			local offset = Vector()
			if bit.band(man.inputFlags, 16) ~= 0 then
				s = 1.5
			end
			if bit.band(man.inputFlags, 4) ~= 0 then
				offset:add(Vector(0, s, 0))
			end
			if bit.band(man.inputFlags, 8) ~= 0 then
				offset:add(Vector(0, -s, 0))
			end

			if man.strafeInput ~= 0 then
				offset:add(Vector(s * man.strafeInput, 0, 0))
			end
			if man.walkInput ~= 0 then
				offset:add(Vector(0, 0, s * -man.walkInput))
			end
			vcl.rigidBody.pos:add(offset)
		end
	end
end

function plugin.hooks.PhysicsBullets ()
	if not disableBul then return end

	local doGC = false
	for _, bul in pairs(bullets.getAll()) do
		bul.time = -1
		doGC = true
	end

	if doGC then
		physics.garbageCollectBullets()
	end

	return hook.override
end

plugin.commands['/fly'] = {
	info = 'Enter a noclip vehicle.',
	canCall = function (ply) return ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	call = function (ply, man)
		assert(man, 'Not spawned in')

		if flyingMachines[man.index] then error('Already flying') end

		local vcl = vehicles.create(69, man.pos, orientations.n, 0)
		if vcl then
			vcl.type = 5
			vcl:updateType()
			vcl.type = 69

			flyingMachines[man.index] = vcl
			vcl.rigidBody.isSettled = true
			man.vehicle = vcl
			man.vehicleSeat = 0
		end

		adminLog('%s is now flying', ply.name)
	end
}

plugin.commands['/physics'] = {
	info = 'Toggle physics.',
	alias = {'/phys'},
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	call = function (ply)
		disablePhys = not disablePhys
		adminLog('%s turned physics %s', ply.name, disablePhys and 'off' or 'on')
	end
}

plugin.commands['/bullets'] = {
	info = 'Toggle bullets.',
	alias = {'/bul'},
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	call = function (ply)
		disableBul = not disableBul
		adminLog('%s turned bullets %s', ply.name, disableBul and 'off' or 'on')
	end
}

return module