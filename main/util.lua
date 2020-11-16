---Convert a pitch angle to a RotMatrix.
---@param pitch number The pitch angle (in radians).
---@return RotMatrix The converted rotation matrix.
function pitchToRotMatrix (pitch)
	local s = math.sin(pitch)
	local c = math.cos(pitch)

	return RotMatrix(
		1, 0, 0,
		0, c, -s,
		0, s, c
	)
end

---Convert a yaw angle to a RotMatrix.
---@param yaw number The yaw angle (in radians).
---@return RotMatrix The converted rotation matrix.
function yawToRotMatrix (yaw)
	local s = math.sin(yaw)
	local c = math.cos(yaw)

	return RotMatrix(
		c, 0, s,
		0, 1, 0,
		-s, 0, c
	)
end

---Convert a roll angle to a RotMatrix.
---@param roll number The roll angle (in radians).
---@return RotMatrix The converted rotation matrix.
function rollToRotMatrix (roll)
	local s = math.sin(roll)
	local c = math.cos(roll)

	return RotMatrix(
		c, -s, 0,
		s, c, 0,
		0, 0, 1
	)
end

---Table of useful compass orientations.
orientations = {
	n = yawToRotMatrix(0),
	ne = yawToRotMatrix(math.pi / 4),
	e = yawToRotMatrix(math.pi / 2),
	se = yawToRotMatrix(math.pi * 3 / 4),
	s = yawToRotMatrix(math.pi),
	sw = yawToRotMatrix(math.pi * 5 / 4),
	w = yawToRotMatrix(math.pi * 3 / 2),
	nw = yawToRotMatrix(math.pi * 7 / 4)
}

---Check if an object is active.
---@param object userdata? The object to check.
---@return boolean isActive Whether the parameter is an active object.
function isActive (object)
	return object and object.isActive
end

---Get a point on a circle.
---@param radius number Radius in units.
---@param angle number Angle in radians.
---@return number x The X coordinate on the circle.
---@return number y The Y coordinate on the circle.
function getCirclePoint (radius, angle)
	return radius * math.cos(angle), radius * math.sin(angle)
end

---@class CirclePoint
---@field x number The X coordinate on the circle.
---@field y number The Y coordinate on the circle.

---Get points on a circle.
---@param numPoints integer The number of points to calculate.
---@param radius number? The radius of the circle in units.
---@param angleOffset number? How much to rotate the entire circle (in radians).
---@return CirclePoint[] points The points on the circle.
function getCirclePoints (numPoints, radius, angleOffset)
	numPoints = math.max(numPoints, 1)
	radius = radius or 1
	angleOffset = angleOffset or 0
	
	local points = {}
	for i = 1, numPoints do
		local angle = (i/numPoints * math.pi*2) + angleOffset
		points[i] = {
			x = radius * math.cos(angle),
			y = radius * math.sin(angle)
		}
	end

	return points
end

---Shuffle a table in place.
---@param tbl any[] The table to shuffle.
---@return any[] tbl The shuffled table.
function table.shuffle (tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

---Determine if a list contains a value.
---@param tbl any[] The table of values to check.
---@param val any The value to check against.
---@return boolean contains Whether the value was found in the table.
function table.contains (tbl, val)
	for _, v in ipairs(tbl) do
		if v == val then return true end
	end
	return false
end

---Get the number of elements in a non-sequential table.
---@param tbl table The table to count the elements of.
---@return integer numElements The number of elements in the table.
function table.numElements (tbl)
	local count = 0
	for _ in pairs(tbl) do count = count + 1 end
	return count
end

---Clamp a number between two bounds.
---@param val number The value to clamp.
---@param lower number The minimum value.
---@param upper any The maximum value.
---@return number clamped The clamped value.
function math.clamp (val, lower, upper)
	if lower > upper then lower, upper = upper, lower end
	return math.max(lower, math.min(upper, val))
end

---Round a number to a fixed number of decimal places.
---@param num number The number to round.
---@param numDecimalPlaces number The number of decimal places to round to.
---@return number rounded The rounded value.
function math.round (num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

---Get a random float between two bounds.
---@param lower number The lower bound.
---@param upper number The upper bound.
---@return number randomFloat The randomly generated float.
function math.randomFloat (lower, upper)
	return lower + math.random() * (upper - lower)
end

---Get the lower and higher of two values.
---@param lower number Any number.
---@param upper number Any number.
---@return number lower The lower of the two numbers.
---@return number upper The upper of the two numbers.
function lowHigh (lower, upper)
	if lower > upper then lower, upper = upper, lower end
	return lower, upper
end

---Check if a number is between two other numbers.
---@param val number The value to check.
---@param lower number Any number.
---@param upper number Any number.
---@return boolean isBetween Whether the number is between the other two values.
function isNumberBetween (val, lower, upper)
	if lower > upper then lower, upper = upper, lower end
	return lower <= val and upper >= val
end

---Check if a vector is in a vertical section.
---The Y coordinates are ignored.
---@param vec Vector The vector to check.
---@param cornerA Vector One of the two corner positions.
---@param cornerB Vector The other corner position.
---@return boolean isInSquare Whether the vector is inside the square.
function isVectorInSquare (vec, cornerA, cornerB)
	return isNumberBetween(vec.x, cornerA.x, cornerB.x)
	and isNumberBetween(vec.z, cornerA.z, cornerB.z)
end

---Check if a vector is in a cuboid.
---@param vec Vector The vector to check.
---@param cornerA Vector One of the two corner positions.
---@param cornerB Vector The other corner position.
---@return boolean isInCuboid Whether the vector is inside the cuboid.
function isVectorInCuboid (vec, cornerA, cornerB)
	return isNumberBetween(vec.x, cornerA.x, cornerB.x)
	and isNumberBetween(vec.z, cornerA.z, cornerB.z)
	and isNumberBetween(vec.y, cornerA.y, cornerB.y)
end

---Get a random vector inside a cuboid.
---@param vec1 Vector One of the two corner positions.
---@param vec2 Vector The other corner position.
---@return Vector randomVector The randomly generated vector in the cuboid.
function vecRandBetween (vec1, vec2)
	local x = math.randomFloat(vec1.x, vec2.x)
	local y = math.randomFloat(vec1.y, vec2.y)
	local z = math.randomFloat(vec1.z, vec2.z)

	return Vector(x, y, z)
end

---Check if a string starts with another string.
---@param start string The string to check against.
---@return boolean startsWith Whether this string starts with the other.
function string:startsWith (start)
	return self:sub(1, #start) == start
end

---Check if a string ends with another string.
---@param ending string The string to check against.
---@return boolean endsWith Whether this string ends with the other.
function string:endsWith (ending)
	return ending == '' or self:sub(-#ending) == ending
end

---Split a string by its whitespace into lines of maximum length.
---@param maxLen integer The maximum length of every line.
---@return string[] lines The split lines.
function string:splitMaxLen (maxLen)
	local lines = {}
	local line

	self:gsub('(%s*)(%S+)', function (spc, word)
		if not line or #line + #spc + #word > maxLen then
			table.insert(lines, line)
			line = word
		else
			line = line .. spc .. word
		end
	end)

	table.insert(lines, line)
	return lines
end

---Split a string into tokens using a separator character.
---@param sep string The separator character.
---@return string[] fields The split tokens.
function string:split (sep)
	sep = sep or ':'
	local fields = {}
	local pattern = string.format('([^%s]+)', sep)
	self:gsub(pattern, function (c) fields[#fields + 1] = c end)
	return fields
end

---Trim whitespace before and after a string.
---@return string trimmed The trimmed string.
function string:trim ()
	return self:gsub('^%s*(.-)%s*$', '%1')
end

---Announce a chat message with word wrapping on long strings.
---@param str string The message to announce.
function chat.announceWrap (str)
	local lines = str:splitMaxLen(63)
	for _, line in ipairs(lines) do
		chat.announce(line)
	end
end

---Announce a chat message to admins with word wrapping on long strings.
---@param str string The message to announce.
function chat.tellAdminsWrap (str)
	local lines = str:splitMaxLen(63)
	for _, line in ipairs(lines) do
		chat.tellAdmins(line)
	end
end

---Send a message to a player with word wrapping on long strings.
---@param ply Player The player to send the message to.
---@param str string The message to announce.
function messagePlayerWrap (ply, str)
	local lines = str:splitMaxLen(63)
	for _, line in ipairs(lines) do
		ply:sendMessage(line)
	end
end

---Format a number with a comma every 3 spaces.
---Ex. 1234567 becomes '1,234,567'.
---@param amount number The number to format.
---@return string formatted The number formatted with commas.
function commaNumber (amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

---Get two points representing a human's line of sight.
---@param man Human The human to get the eye line of.
---@param distance number The distance in units the line should be.
---@return Vector posA The first point of the line.
---@return Vector posB The second point of the line.
function getEyeLine (man, distance)
	local body = man:getRigidBody(3)
	local posA = body.pos:clone()

	local yaw = man.viewYaw - math.pi/2
	local pitch = -man.viewPitch

	local posB = Vector(
		math.cos(yaw) * math.cos(pitch),
		math.sin(pitch),
		math.sin(yaw) * math.cos(pitch)
	)
	posB:mult(distance)
	posB:add(posA)

	return posA, posB
end

---Format a phone number ID with a dash.
---Ex. 2564096 becomes '256-4096'.
---@param phoneNumber integer|string The phone number to format.
---@return string dashedNumber The phone number with an added dash.
function dashPhoneNumber (phoneNumber)
	local str = tostring(phoneNumber):gsub('(%d%d%d)(%d%d%d%d)', '%1-%2')
	return str
end

---Convert a phone number ID which might have a dash back to its integer value.
---Ex. '256-4096' becomes 2564096.
---@param str string The phone number which may or may not have a dash.
---@return integer phoneNumber The integer value of the phone number.
function undashPhoneNumber (str)
	str = str:gsub('(%d%d%d)-(%d%d%d%d)', '%1%2')
	return tonumber(str)
end

---Find a single player represented by an input.
---Meant to be used in commands. Throws errors.
---@param input string Part of a player name or a phone number (with or without a dash).
---@return Player player The only player represented by the input.
function findOnePlayer (input)
	local allPlayers = players.getNonBots()

	local phoneNumber = undashPhoneNumber(input)
	if phoneNumber then
		for _, ply in ipairs(allPlayers) do
			if ply.phoneNumber == phoneNumber then
				return ply
			end
		end
	end

	local lastFound
	input = input:lower()

	for _, ply in ipairs(allPlayers) do
		if ply.name:lower():find(input) then
			if lastFound ~= nil then
				error('Multiple players found, be more specific')
			end
			lastFound = ply
		end
	end

	if lastFound then
		return lastFound
	end

	error('Player not found')
end

---Find a single account represented by an input.
---Meant to be used in commands. Throws errors.
---@param input string Part of a player name or a phone number (with or without a dash).
---@return Account account The only account represented by the input.
function findOneAccount (input)
	local allAccounts = accounts.getAll()

	local phoneNumber = undashPhoneNumber(input)
	if phoneNumber then
		for _, acc in ipairs(allAccounts) do
			if acc.phoneNumber == phoneNumber then
				return acc
			end
		end
	end

	local lastFound
	input = input:lower()

	for _, acc in ipairs(allAccounts) do
		if acc.name:lower():find(input) then
			if lastFound ~= nil then
				error('Multiple accounts found, be more specific')
			end
			lastFound = acc
		end
	end

	if lastFound then
		return lastFound
	end

	error('Account not found')
end

---Auto complete a matching account by a name or phone number.
---@param input string The name or phone number to auto complete.
---@return string? result The name or dashed phone number of the found account, if any.
---@return Account? account The found account, if any.
function autoCompleteAccount (input)
	input = input:lower()

	for _, acc in ipairs(accounts.getAll()) do
		if tostring(acc.phoneNumber):find(input) then
			return dashPhoneNumber(acc.phoneNumber), acc
		end

		if acc.name:lower():find(input) then
			return acc.name, acc
		end
	end

	return nil, nil
end

---Auto complete a matching player by a name or phone number.
---@param input string The name or phone number to auto complete.
---@return string? result The name or dashed phone number of the found player, if any.
---@return Player? player The found player, if any.
function autoCompletePlayer (input)
	input = input:lower()

	for _, ply in ipairs(players.getAll()) do
		if tostring(ply.phoneNumber):find(input) then
			return dashPhoneNumber(ply.phoneNumber), ply
		end

		if ply.name:lower():find(input) then
			return ply.name, ply
		end
	end

	return nil, nil
end

---Convert all arguments to strings and concatenate.
---@param separator string The string to join two arguments with.
---@vararg any The values to concatenate.
function concatVarArgs (separator, ...)
	local numArgs = select('#', ...)
	local args = {...}

	local str = ''
	local doneFirst = false

	for i = 1, numArgs do
		if doneFirst then
			str = str .. separator
		else
			doneFirst = true
		end

		str = str .. tostring(args[i])
	end

	return str
end