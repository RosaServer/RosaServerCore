local plugin = ...
local module = {}

local shared = plugin:require('shared')
local persistence = plugin:require('persistence')

local visibleModerators
local awaitConnected
local hiddenPlayers

function module.onEnable ()
	visibleModerators = {}
	awaitConnected = {}
end

function module.onDisable ()
	visibleModerators = nil
	awaitConnected = nil
end

---Check if a player is a moderator.
---@param ply Player The player to check.
---@return boolean isModerator Whether the player is a moderator.
function isModerator (ply)
	return persistence.get().moderators[tostring(ply.phoneNumber)] == true
end

---Check if a player is a moderator or an admin.
---@param ply Player The player to check.
---@return boolean isModeratorOrAdmin Whether the player is a moderator or an admin.
function isModeratorOrAdmin (ply)
	return ply.isAdmin or persistence.get().moderators[tostring(ply.phoneNumber)] == true
end

---Check if a player is a moderator and hidden.
---@param ply Player The player to check.
---@return boolean isHiddenModerator Whether the player is a hidden moderator.
function isHiddenModerator (ply)
	return isModerator(ply) and not visibleModerators[ply.index]
end

function plugin.hooks.PostPlayerCreate (ply)
	awaitConnected[ply.index] = true
	visibleModerators[ply.index] = nil
end

function plugin.hooks.PostPlayerDelete (ply)
	awaitConnected[ply.index] = nil
	visibleModerators[ply.index] = nil
end

function module.hookLogic ()
	for index, _ in pairs(awaitConnected) do
		local ply = players[index]
		if ply.isBot then
			awaitConnected[index] = nil
		else
			local con = ply.connection
			if con then
				awaitConnected[index] = nil
				if isModerator(ply) then
					con.adminVisible = true
				end
			end
		end
	end
end

function plugin.hooks.WebUploadBody ()
	hiddenPlayers = {}

	for _, ply in pairs(players.getNonBots()) do
		if isHiddenModerator(ply) then
			table.insert(hiddenPlayers, ply)
			ply.isBot = true
		end
	end
end

function plugin.hooks.PostWebUploadBody (body)
	for _, ply in pairs(hiddenPlayers) do
		ply.isBot = false
	end

	hiddenPlayers = nil
end

do
	local isInsideInPacket
	local shouldIgnoreMessage
	local hidingAsBot

	function plugin.hooks.InPacket ()
		isInsideInPacket = true
	end

	function plugin.hooks.EventUpdatePlayer (ply)
		if not ply.isBot and isHiddenModerator(ply) then
			hidingAsBot = true
			ply.isBot = true
		end
	end

	function plugin.hooks.PostEventUpdatePlayer (ply)
		if hidingAsBot then
			hidingAsBot = nil
			ply.isBot = false
		end

		if isInsideInPacket and isHiddenModerator(ply) then
			shouldIgnoreMessage = true
		end
	end

	function plugin.hooks.EventMessage (type, message, speakerID, distance)
		if shouldIgnoreMessage then
			shouldIgnoreMessage = nil
			plugin:print('Silencing moderator status message: ' .. message)
			return hook.override
		end
	end

	function plugin.hooks.PostInPacket ()
		isInsideInPacket = nil
		shouldIgnoreMessage = nil
	end
end

plugin.commands['/mod'] = {
	info = 'Add a moderator.',
	usage = '/mod <phoneNumber/name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local acc = findOneAccount(table.remove(args, 1))
		local phoneString = tostring(acc.phoneNumber)

		local persistentData = persistence.get()

		if persistentData.moderators[phoneString] then
			error('Already a moderator')
		end

		persistentData.moderators[phoneString] = true
		persistence.save()

		adminLog('%s added %s (%s) as a moderator', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber))

		shared.discordEmbed({
			title = 'Moderator Added',
			color = 0x0288D1,
			description = string.format('**%s** added **%s** (%s) as a moderator', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber))
		})

		local accPly = players.getByPhone(acc.phoneNumber)
		if accPly then
			visibleModerators[accPly.index] = true
			if accPly.connection then
				accPly.connection.adminVisible = true
			end
		end
	end
}

plugin.commands['/unmod'] = {
	info = 'Remove a moderator.',
	usage = '/unmod <phoneNumber/name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local acc = findOneAccount(table.remove(args, 1))
		local phoneString = tostring(acc.phoneNumber)

		local persistentData = persistence.get()

		if not persistentData.moderators[phoneString] then
			error('Not already a moderator')
		end

		persistentData.moderators[phoneString] = nil
		persistence.save()

		adminLog('%s removed %s (%s) as a moderator', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber))

		shared.discordEmbed({
			title = 'Moderator Removed',
			color = 0x0288D1,
			description = string.format('**%s** removed **%s** (%s) as a moderator', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber))
		})

		local accPly = players.getByPhone(acc.phoneNumber)
		if accPly then
			visibleModerators[accPly.index] = nil
			if accPly.connection then
				accPly.connection.adminVisible = false
			end
		end
	end
}

plugin.commands['/leave'] = {
	info = 'Pretend to leave.',
	canCall = isModeratorOrAdmin,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		if not visibleModerators[ply.index] then
			error('Already left')
		end

		visibleModerators[ply.index] = nil
		chat.announce(ply.name .. ' Exited')

		if not hook.run('EventUpdatePlayer', ply) then
			ply:update()
			hook.run('PostEventUpdatePlayer', ply)
		end
	end
}

plugin.commands['/join'] = {
	info = 'Pretend to join.',
	canCall = isModeratorOrAdmin,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		if visibleModerators[ply.index] then
			error('Already joined')
		end

		visibleModerators[ply.index] = true
		chat.announce(ply.name .. ' Joined')

		if not hook.run('EventUpdatePlayer', ply) then
			ply:update()
			hook.run('PostEventUpdatePlayer', ply)
		end
	end
}

return module