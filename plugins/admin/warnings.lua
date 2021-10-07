---@type Plugin
local plugin = ...

local shared = plugin:require('shared')
local persistence = plugin:require('persistence')

local DISPLAY_FREQUENCY_SECONDS = 15
local STAGGER_DIVISIONS = 30
local DIVIDER_LENGTH = 48

local function displayWarning (ply, warning)
	local line = ('-'):rep(DIVIDER_LENGTH)
	local dateString = os.date('%B %d at %I:%M %p %Z', warning.time)

	ply:sendMessage(line)
	messagePlayerWrap(ply, 'You have a warning from ' .. dateString .. ':')
	messagePlayerWrap(ply, warning.reason)
	ply:sendMessage('Type /warned to acknowledge.')
	ply:sendMessage(line)
end

local displayRoutine = staggerRoutine(
	players.getNonBots,
	STAGGER_DIVISIONS,
	---@param ply Player
	---@param persistentData table
	---@param now number
	function (ply, persistentData, now)
		local phoneString = tostring(ply.phoneNumber)
		local warnings = persistentData.warnings[phoneString]

		if warnings then
			local warning = warnings[1]

			if warning then
				local data = ply.data
				if data.adminLastWarningDisplayTime
				and now - data.adminLastWarningDisplayTime < DISPLAY_FREQUENCY_SECONDS then
					return
				end

				data.adminLastWarningDisplayTime = now
				displayWarning(ply, warning)
			end
		end
	end
)

plugin:addHook(
	'Logic',
	function ()
		local persistentData = persistence.get()
		local now = os.realClock()
		displayRoutine(persistentData, now)
	end
)

plugin.commands['/warn'] = {
	info = 'Warn a player.',
	usage = '<phoneNumber/name> <reason>',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 2, 'usage')

		local acc = findOneAccount(table.remove(args, 1))

		local phoneString = tostring(acc.phoneNumber)
		local reason = table.concat(args, ' ')

		local persistentData = persistence.get()

		if not persistentData.warnings[phoneString] then
			persistentData.warnings[phoneString] = {}
		end

		table.insert(persistentData.warnings[phoneString], {
			reason = reason,
			time = os.time()
		})
		persistence.save()

		adminLog('%s warned %s (%s), reason: %s', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber), reason)

		shared.discordEmbed({
			title = 'Player Warned',
			color = 0xFBC02D,
			description = string.format('**%s** warned **%s** (%s)', ply.name, acc.name, dashPhoneNumber(acc.phoneNumber)),
			fields = {
				{
					name = 'Reason',
					value = reason
				}
			}
		})
	end
}

plugin.commands['/warned'] = {
	info = 'Acknowledge a warning.',
	canCall = function (ply) return not ply.isConsole end,
	---@param ply Player
	call = function (ply)
		local phoneString = tostring(ply.phoneNumber)

		local persistentData = persistence.get()

		if not persistentData.warnings[phoneString] then
			error("You don't have any warnings")
		end

		local warning = table.remove(persistentData.warnings[phoneString], 1)

		if #persistentData.warnings[phoneString] == 0 then
			persistentData.warnings[phoneString] = nil
		end

		persistence.save()

		messagePlayerWrap(ply, 'Warning acknowledged: ' .. warning.reason)
		adminLog('%s (%s) acknowledged their warning: %s', ply.name, dashPhoneNumber(ply.phoneNumber), warning.reason)
	end
}