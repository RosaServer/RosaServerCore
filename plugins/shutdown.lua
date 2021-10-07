---@type Plugin
local plugin = ...
plugin.name = 'Shutdown'
plugin.author = 'jdb'
plugin.description = 'Adds the /shutdown command.'

local shuttingDown
local ticksRemaining
local reason

plugin:addEnableHandler(function ()
	shuttingDown = false
	ticksRemaining = 0
	reason = nil
end)

plugin:addDisableHandler(function ()
	shuttingDown = nil
	ticksRemaining = nil
	reason = nil
end)

local function shutdown ()
	accounts.save()

	for _, plug in pairs(hook.plugins) do
		plug:disable()
	end

	plugin:print('Goodbye!')
	os.exit()
end

plugin.commands['/shutdown'] = {
	info = 'Begin or cancel shutdown.',
	usage = '<seconds/"now"> [reason]',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param args string[]
	autoComplete = function (args)
		if #args < 1 then return end

		if ('now'):startsWith(args[1]:lower()) then
			args[1] = 'now'
		end
	end,
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		assert(#args >= 1, 'usage')

		if args[1]:lower() == 'now' then
			if adminLog then
				adminLog('%s initiated instant shutdown', ply.name)
			end
			shutdown()
			return
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

		local seconds = math.max(math.floor(table.remove(args, 1)), 0)
		reason = #args > 0 and table.concat(args, ' ') or nil

		shuttingDown = true
		ticksRemaining = seconds * server.TPS

		ply:sendMessage(string.format('Shutdown initated (%is)', seconds))
		if adminLog then
			adminLog('%s initiated shutdown (%is, %s)', ply.name, seconds, reason)
		end
	end
}

plugin:addHook(
	'Logic',
	function ()
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
)