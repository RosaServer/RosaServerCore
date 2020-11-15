local plugin = ...

local shared = plugin:require('shared')
local persistence = plugin:require('persistence')

plugin.commands['/kick'] = {
	info = 'Kick a player.',
	usage = '/kick <phoneNumber/name> [reason]',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	autoComplete = shared.autoCompletePlayerFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local victim = findOnePlayer(table.remove(args, 1))
		if not victim.connection then error('Player not connected') end

		local reason = #args > 0 and table.concat(args, ' ') or 'No reason specified.'

		victim.connection.timeoutTime = 50 * server.TPS

		adminLog('%s kicked %s (%s), reason: %s', ply.name, victim.name, dashPhoneNumber(victim.phoneNumber), reason)

		shared.discordEmbed({
			title = 'Player Kicked',
			color = 0xF57C00,
			description = string.format('**%s** kicked **%s** (%s)', ply.name, victim.name, dashPhoneNumber(victim.phoneNumber)),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/punish'] = {
	info = 'Ban an account based on previous bans.',
	usage = '/punish <phoneNumber/name> [reason]',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local acc = findOneAccount(table.remove(args, 1))

		local phoneString = tostring(acc.phoneNumber)
		local reason = #args > 0 and table.concat(args, ' ') or 'No reason specified.'

		local persistentData = persistence.get()

		persistentData.punishments[phoneString] = persistentData.punishments[phoneString] or 0
		local banMinutes = 45 * (2 ^ persistentData.punishments[phoneString])
		persistentData.punishments[phoneString] = persistentData.punishments[phoneString] + 1

		if not persistentData.warnings[phoneString] then
			persistentData.warnings[phoneString] = {}
		end

		table.insert(persistentData.warnings[phoneString], {
			reason = 'Banned for ' .. banMinutes .. 'm: ' .. reason,
			time = os.time()
		})

		persistence.save()

		acc.banTime = acc.banTime + banMinutes

		adminLog('%s punished %s (%s) @ %im, reason: %s', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banMinutes, reason)

		shared.discordEmbed({
			title = 'Player Banned',
			color = 0xD32F2F,
			description = string.format('**%s** added a punishment to **%s** (%s), ban set at **%im**', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banMinutes),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/unpunish'] = {
	info = 'Remove a punishment from an account.',
	usage = '/unpunish <phoneNumber/name> [reason]',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local acc = findOneAccount(table.remove(args, 1))

		local phoneString = tostring(acc.phoneNumber)
		local reason = #args > 0 and table.concat(args, ' ') or 'No reason specified.'

		local persistentData = persistence.get()

		if not persistentData.punishments[phoneString] or persistentData.punishments[phoneString] < 1 then error('Account has no punishment') end

		local banMinutes = 45 * (2 ^ (persistentData.punishments[phoneString] - 1))
		persistentData.punishments[phoneString] = persistentData.punishments[phoneString] - 1
		persistence.save()

		acc.banTime = math.max(0, acc.banTime - banMinutes)

		adminLog('%s unpunished %s (%s) @ %im, reason: %s', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banMinutes, reason)

		shared.discordEmbed({
			title = 'Player Unbanned',
			color = 0x388E3C,
			description = string.format('**%s** removed a punishment from **%s** (%s), deducted **%im**', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banMinutes),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/ban'] = {
	info = 'Ban an account.',
	usage = '/ban <phoneNumber/name> <minutes> [reason]',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 2, 'usage')

		local acc = findOneAccount(table.remove(args, 1))

		local banTime = math.floor(table.remove(args, 1) or 0)
		if banTime < 1 then error('Invalid ban time') end

		local reason = #args > 0 and table.concat(args, ' ') or 'No reason specified.'

		acc.banTime = banTime

		adminLog('%s banned %s (%s) for %imin, reason: %s', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banTime, reason)

		shared.discordEmbed({
			title = 'Player Banned',
			color = 0xD32F2F,
			description = string.format('**%s** manually banned **%s** (%s) for **%imin**', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), banTime),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/unban'] = {
	info = 'Unban an account.',
	usage = '/unban <phoneNumber/name> [reason]',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local acc = findOneAccount(table.remove(args, 1))

		local reason = #args > 0 and table.concat(args, ' ') or 'No reason specified.'

		acc.banTime = 0

		adminLog('%s unbanned %s (%s), reason: %s', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), reason)

		shared.discordEmbed({
			title = 'Player Unbanned',
			color = 0x388E3C,
			description = string.format('**%s** manually unbanned %s (%s)', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber)),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/kill'] = {
	info = 'Kill a player.',
	usage = '/kill <phoneNumber/name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	autoComplete = shared.autoCompletePlayerFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		local victim = findOnePlayer(table.remove(args, 1))

		local victimMan = victim.human
		assert(victimMan, 'Victim not spawned in')

		victimMan.isAlive = false

		adminLog('%s killed %s (%s)', ply.name, victim.name, dashPhoneNumber(victim.phoneNumber))
	end
}