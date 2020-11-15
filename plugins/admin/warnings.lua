local plugin = ...
local module = {}

local shared = plugin:require('shared')
local persistence = plugin:require('persistence')

local warningDisplayEvery = 15 * server.TPS

local warningDisplayTimer

function module.onEnable ()
	warningDisplayTimer = 0
end

function module.onDisable ()
	warningDisplayTimer = nil
end

local function displayWarnings()
	local persistentData = persistence.get()

	for _, ply in ipairs(players.getNonBots()) do
		local phoneString = tostring(ply.phoneNumber)
		local warnings = persistentData.warnings[phoneString]

		if warnings then
			local line = ('-'):rep(48)
			local warning = warnings[1]
			local dateString = os.date('%B %d at %I:%M %p %Z')

			ply:sendMessage(line)
			messagePlayerWrap(ply, 'You have a warning from ' .. dateString .. ':')
			messagePlayerWrap(ply, warning.reason)
			ply:sendMessage('Type /warned to acknowledge.')
			ply:sendMessage(line)
		end

		if isHiddenModerator(ply) then
			ply:sendMessage('Note: You are currently hidden from the UI. (/join, /leave)')
		end
	end
end

function module.hookLogic ()
	warningDisplayTimer = warningDisplayTimer + 1
	if warningDisplayTimer == warningDisplayEvery then
		warningDisplayTimer = 0
		displayWarnings()
	end
end

plugin.commands['/warn'] = {
	info = 'Warn a player.',
	usage = '/warn <phoneNumber/name> <reason>',
	canCall = function (ply) return ply.isConsole or isModeratorOrAdmin(ply) end,
	autoComplete = shared.autoCompleteAccountFirstArg,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
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
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
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

return module