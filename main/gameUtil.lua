---Check if an object is active.
---@param object userdata? The object to check.
---@return boolean isActive Whether the parameter is an active object.
function isActive (object)
	return object and object.isActive
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
	if ply.isConsole then
		ply:sendMessage(str)
	else
		local lines = str:splitMaxLen(63)
		for _, line in ipairs(lines) do
			ply:sendMessage(line)
		end
	end
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