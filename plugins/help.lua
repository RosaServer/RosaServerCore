---@type Plugin
local plugin = ...
plugin.name = 'Help'
plugin.author = 'jdb'
plugin.description = 'Adds the /help command.'

plugin.commands['/help'] = {
	info = 'Get some help.',
	usage = '[page]',
	---@param ply Player
	---@param args string[]
	call = function (ply, _, args)
		local page = math.max(math.floor(tonumber(args[1]) or 1), 1)
		local perPage = ply.isConsole and 10 or 4

		local commands = hook.getCommands()
		local allowedCommands = {}

		for name, command in pairs(commands) do
			if hook.canCallCommand(name, command, ply) then
				table.insert(allowedCommands, {
					name = name,
					command = command
				})
			end
		end

		table.sort(allowedCommands, function (a, b)
			return a.name < b.name
		end)

		local maxPage = math.ceil(#allowedCommands / perPage)
		if page > maxPage then error('Page too high') end

		local sliceStart = (page - 1) * perPage + 1
		local sliceEnd = page * perPage

		if not ply.data.helpArgsWarned then
			ply:sendMessage('Note: <arguments> are required, [arguments] are optional.')
			ply.data.helpArgsWarned = true
		end

		ply:sendMessage('----- Page ' .. page .. ' of ' .. maxPage .. ' -----')
		local sliced = {unpack(allowedCommands, sliceStart, sliceEnd)}
		for _, allowed in pairs(sliced) do
			local str = allowed.name
			local command = allowed.command

			if type(command) == 'table' then
				if command.usage then
					str = str .. ' ' .. command.usage
				end
				if command.info then
					str = str .. ' - ' .. command.info
				end
			end

			ply:sendMessage(str)
		end
	end
}