---@type Plugin
local plugin = ...
plugin.name = 'Where'
plugin.author = 'jdb'
plugin.description = 'Locate players.'

---@param pos Vector
---@return Street?
local function getStreetUnderPosition (pos)
	for _, street in ipairs(streets.getAll()) do
		if isVectorInCuboid(pos, street.trafficCuboidA, street.trafficCuboidB) then
			return street
		end
	end
end

---@param pos Vector
---@return StreetIntersection?
---@return number?
local function getClosestIntersection (pos)
	local lowestSquareDistance
	local closestIntersection

	for _, intersection in ipairs(intersections.getAll()) do
		local squareDistance = intersection.pos:distSquare(pos)
		if not lowestSquareDistance or squareDistance < lowestSquareDistance then
			lowestSquareDistance = squareDistance
			closestIntersection = intersection
		end
	end

	return closestIntersection, lowestSquareDistance
end

---@param intersection StreetIntersection
---@return string
local function getIntersectionHorizontalName (intersection)
	local street = intersection.streetEast or intersection.streetWest
	return street and street.name or 'n/a'
end

---@param intersection StreetIntersection
---@return string
local function getIntersectionVerticalName (intersection)
	local street = intersection.streetNorth or intersection.streetSouth
	return street and street.name or 'n/a'
end

---@param intersection StreetIntersection
local function intersectionToString (intersection)
	return getIntersectionHorizontalName(intersection) .. ' and ' .. getIntersectionVerticalName(intersection)
end

---@param street Street
local function isStreetVertical (street)
	local intersection = street.intersectionA
	if intersection.streetSouth == street or intersection.streetNorth == street then
		return true
	end
	return false
end

---@param street Street
local function handleOnStreet (street)
	local betweenA, betweenB
	if isStreetVertical(street) then
		betweenA = getIntersectionHorizontalName(street.intersectionA)
		betweenB = getIntersectionHorizontalName(street.intersectionB)
	else
		betweenA = getIntersectionVerticalName(street.intersectionA)
		betweenB = getIntersectionVerticalName(street.intersectionB)
	end

	return string.format(
		'on %s between %s and %s',
		street.name or 'n/a',
		betweenA,
		betweenB
	)
end

---@param intersection StreetIntersection
---@param distance number
local function handleNearIntersection (intersection, distance)
	return string.format(
		'%.2fm away from %s',
		distance,
		intersectionToString(intersection)
	)
end

plugin.commands['/where'] = {
	info = 'Locate a player.',
	usage = '/where <phoneNumber/name>',
	---@param ply Player
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param args string[]
	autoComplete = function (args)
		if #args < 1 then return end

		local result = autoCompletePlayer(args[1])
		if result then
			args[1] = result
		end
	end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		local victim = findOnePlayer(table.remove(args, 1))

		local context = 'not spawned in'

		local victimMan = victim.human
		if victimMan then
			local onStreet = getStreetUnderPosition(victimMan.pos)
			if onStreet then
				context = handleOnStreet(onStreet)
			else
				local closestIntersection, squareDistance = getClosestIntersection(victimMan.pos)
				assert(closestIntersection, 'There are no street intersections to refer to')
		
				context = handleNearIntersection(closestIntersection, math.sqrt(squareDistance))
			end
		end

		messagePlayerWrap(ply, string.format(
			'%s (%s) is %s',
			victim.name,
			dashPhoneNumber(victim.phoneNumber),
			context
		))
	end
}