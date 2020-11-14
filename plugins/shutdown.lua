local plugin = ...
plugin.name = 'Shutdown'
plugin.author = 'jdb'
plugin.description = 'Adds the /shutdown command.'

local shuttingDown
local ticksRemaining
local reason

function plugin.onEnable ()
	shuttingDown = false
	ticksRemaining = 0
	reason = nil
end

function plugin.onDisable ()
	shuttingDown = nil
	ticksRemaining = nil
	reason = nil
end

local function shutdown ()
	accounts.save()

	for _, plugin in pairs(hook.plugins) do
		plugin:disable()
	end

	print('Goodbye!')
	os.exit()
end

plugin.commands['/shutdown'] = {
	info = 'Begin or cancel shutdown.',
	usage = '/shutdown [minutes/"now"]',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		if args[1] == 'now' then
			if adminLog then
				adminLog('%s initiated instant shutdown', ply.name)
				shutdown()
				return
			end
		end

		if shuttingDown then
			shuttingDown = false
			reason = nil

			ply:sendMessage('Shutdown cancelled')
			if adminLog then
				adminLog('%s cancelled shutdown', ply.name)
			end

			return
		end

		local seconds = math.max(math.floor(table.remove(args, 1) or 30), 0)
		reason = #args > 0 and table.concat(args, ' ') or nil

		shuttingDown = true
		ticksRemaining = seconds * server.TPS

		ply:sendMessage(string.format('Shutdown initated (%is)', seconds))
		if adminLog then
			adminLog('%s initiated shutdown (%is, %s)', ply.name, seconds, reason)
		end
	end
}

function plugin.hooks.Logic ()
	if shuttingDown then
		if ticksRemaining <= 0 then
			shutdown()
			return
		end

		local secondsRemaining = ticksRemaining / server.TPS
		local messageFrequency = 60
		local doMinutes = true

		if secondsRemaining < 60 then
			messageFrequency = 30
			doMinutes = false

			if secondsRemaining < 30 then
				messageFrequency = 10

				if secondsRemaining <= 5 then
					messageFrequency = 1
				end
			end
		end

		if ticksRemaining % (messageFrequency * server.TPS) == 0 then
			local timeString

			if doMinutes then
				timeString = (secondsRemaining / 60) .. 'm'
			else
				timeString = secondsRemaining .. 's'
			end

			if reason then
				timeString = timeString .. ' (' .. reason .. ')'
			end

			chat.announceWrap('[!] Server shutting down in ' .. timeString)
			plugin:print('Shutting down in ' .. timeString)
		end

		ticksRemaining = ticksRemaining - 1
	end
end