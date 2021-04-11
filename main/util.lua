local mathSin = math.sin
local mathCos = math.cos
local mathMax = math.max
local mathMin = math.min
local mathRandom = math.random
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local RotMatrix = RotMatrix
local Vector = Vector

---Convert a pitch angle to a RotMatrix.
---@param pitch number The pitch angle (in radians).
---@return RotMatrix The converted rotation matrix.
function pitchToRotMatrix (pitch)
	local s = mathSin(pitch)
	local c = mathCos(pitch)

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
	local s = mathSin(yaw)
	local c = mathCos(yaw)

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
	local s = mathSin(roll)
	local c = mathCos(roll)

	return RotMatrix(
		c, -s, 0,
		s, c, 0,
		0, 0, 1
	)
end

---Convert an axis-angle rotation to a RotMatrix.
---@param axis Vector The axis unit vector.
---@param angle number The rotation angle (in radians).
function axisAngleToRotMatrix (axis, angle)
	local s = mathSin(angle)
	local c = mathCos(angle)
	local C = 1 - c

	local x = axis.x
	local y = axis.y
	local z = axis.z

	return RotMatrix(
		x*x*C + c, x*y*C - z*s, x*z*C + y*s,
		y*x*C + z*s, y*y*C + c, y*z*C - x*s,
		z*x*C - y*s, z*y*C + x*s, z*z*C + c
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

---Get a point on a circle.
---@param radius number Radius in units.
---@param angle number Angle in radians.
---@return number x The X coordinate on the circle.
---@return number y The Y coordinate on the circle.
function getCirclePoint (radius, angle)
	return radius * mathCos(angle), radius * mathSin(angle)
end

---@class CirclePoint
---@field x number The X coordinate on the circle.
---@field y number The Y coordinate on the circle.

---Get points on a circle.
---@param numPoints integer The number of points to calculate.
---@param radius? number The radius of the circle in units.
---@param angleOffset? number How much to rotate the entire circle (in radians).
---@return CirclePoint[] points The points on the circle.
function getCirclePoints (numPoints, radius, angleOffset)
	numPoints = mathMax(numPoints, 1)
	radius = radius or 1
	angleOffset = angleOffset or 0

	local points = {}
	for i = 1, numPoints do
		local angle = (i/numPoints * math.pi*2) + angleOffset
		points[i] = {
			x = radius * mathCos(angle),
			y = radius * mathSin(angle)
		}
	end

	return points
end

---Shuffle a table in place.
---@param tbl any[] The table to shuffle.
---@return any[] tbl The shuffled table.
function table.shuffle (tbl)
	for i = #tbl, 2, -1 do
		local j = mathRandom(i)
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

---Get a list of all keys in a table.
---@param tbl table The table to get the keys of.
---@return any[] keys The keys in the table.
function table.keys (tbl)
	local keys = {}
	local n = 0

	for key, _ in pairs(tbl) do
		n = n + 1
		keys[n] = key
	end

	return keys
end

---Clamp a number between two bounds.
---@param val number The value to clamp.
---@param lower number The minimum value.
---@param upper any The maximum value.
---@return number clamped The clamped value.
function math.clamp (val, lower, upper)
	if lower > upper then lower, upper = upper, lower end
	return mathMax(lower, mathMin(upper, val))
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
	return lower + mathRandom() * (upper - lower)
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
---@return integer? phoneNumber The integer value of the phone number.
function undashPhoneNumber (str)
	str = str:gsub('(%d%d%d)-(%d%d%d%d)', '%1%2')
	return tonumber(str)
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

---@param columnWidths integer[]
---@param padding integer
local function getHorizontalLine (columnWidths, padding)
	local line = '+'

	for _, width in ipairs(columnWidths) do
		line = line .. ('-'):rep(width + padding * 2) .. '+'
	end

	return line
end

---@param row any[]
---@param columnWidths integer[]
local function getRowString (row, columnWidths, padding)
	local str = '|'

	for column, width in ipairs(columnWidths) do
		str = str .. (' '):rep(padding)
		local cell = tostring(row[column])
		str = str .. cell
		str = str .. (' '):rep(width - #cell + padding)
		str = str .. '|'
	end

	return str
end

---@param rows table[] An array of columns which will be printed as a clean table.
function drawTable (rows)
	if #rows == 0 then return end

	local padding = 1
	local columnWidths = {}

	for columnID, _ in ipairs(rows[1]) do
		local max = 0

		for _, row in ipairs(rows) do
			local cell = tostring(row[columnID])
			if #cell > max then
				max = #cell
			end
		end

		columnWidths[columnID] = max
	end

	local line = getHorizontalLine(columnWidths, padding)
	print(line)

	for _, row in ipairs(rows) do
		print(getRowString(row, columnWidths, padding))
		print(line)
	end
end

---Get a function to lazily stagger over a table-generating function.
---For example, `staggerRoutine(humans.getAll, 10, function (human) ... end)` will generate a function which might be used as a hook for doing some logic on humans in 10 groups.
---@param listGenerator fun(): any[] A function which returns a table to stagger over.
---@param numDivisions integer How many different divisions to cycle through. Every entry in a generated list will be handled every N calls to the returned function. Lower values will handle entries more frequently at the cost of performance.
---@param handler fun(entry: any, ...) The function to be run for every covered entry during a call.
---@return fun(...) routine The function which can be called to get the table and cycle one group. Arguments are passed to `handler`.
function staggerRoutine (listGenerator, numDivisions, handler)
	local counter = 1

	return function (...)
		local list = listGenerator()

		for index = counter, #list, numDivisions do
			handler(list[index], ...)
		end

		counter = (counter % numDivisions) + 1
	end
end