print('Alpha ' .. server.version .. ', ' .. _VERSION .. ', ' .. jit.version)

math.randomseed(os.time())

require('main.util')
require('main.hook')

local chatCooldowns = {}
local chatCooldownSeconds = 0.5

local function splitArguments (str)
	local args = {}
	local split = str:split(' ')

	local inQuotes
	for _, word in pairs(split) do
		if word:startsWith('"') then
			inQuotes = word
		elseif inQuotes ~= nil then
			inQuotes = inQuotes .. ' ' .. word
		end

		if inQuotes ~= nil then
			if word:endsWith('"') then
				table.insert(args, inQuotes:sub(2, -2))
				inQuotes = nil
			end
		else
			table.insert(args, word)
		end
	end

	return args
end

local function handleChatCommandError (ply, commandName, command, result)
	local errorString = tostring(result)
	local _, endPos = errorString:find(': ')
	local stripped = errorString:sub(endPos + 1)

	if stripped == 'usage' then
		local usage = command.usage or commandName
		ply:sendMessage('Usage: ' .. usage)
	else
		if not ply.isAdmin then
			errorString = stripped
		end

		messagePlayerWrap(ply, 'Error: ' .. errorString)
	end
end

local function attemptChatCommand (ply, message)
	local args = splitArguments(message)
	local commandName = table.remove(args, 1)
	local command = hook.findCommand(commandName)

	if not command then
		return hook.continue
	end

	local success, result = pcall(hook.runCommand, commandName, command, ply, ply.human, args)
	if not success then
		handleChatCommandError(ply, commandName, command, result)
	end

	return hook.override
end

hook.add(
	'PlayerChat', 'main',
	function (ply, message)
		local now = os.clock()

		-- Rate limit chat for non-admins
		if not ply.isAdmin and chatCooldowns[ply.index] ~= nil
		and chatCooldowns[ply.index] + chatCooldownSeconds > now then
			return hook.override
		end

		chatCooldowns[ply.index] = now

		-- Run Lua commands
		if message:startsWith('/') then
			return attemptChatCommand(ply, message)
		end
	end
)

local consolePlayer = {
	isConsole = true,
	name = 'Big Brother',
	data = {},
	sendMessage = function (_, ...)
		printAppend('\27[31;1m')
		print(...)
		printAppend('\27[0m')
	end
}

hook.add(
	'ConsoleInput', 'main',
	function (message)
		local args = splitArguments(message)
		local name = table.remove(args, 1)
		if not name then return end

		if not name:startsWith('/') then
			-- Commands that don't start with / can only be invoked by the console
			if hook.runCommand(name, hook.findCommand(name), args) then
				return
			end

			-- Allow calling regular commands without a preceding slash
			if hook.runCommand('/' .. name, hook.findCommand('/' .. name), consolePlayer, nil, args) then
				return
			end
		else
			if hook.runCommand(name, hook.findCommand(name), consolePlayer, nil, args) then
				return
			end
		end

		print('Command "'..name..'" not found!')
	end
)

local function serializeCommand (name, args)
	local str = name .. ' '

	for _, arg in ipairs(args) do
		if arg:find(' ') then
			str = str .. '"' .. arg .. '" '
		else
			str = str .. arg .. ' '
		end
	end

	return str
end

hook.add(
	'ConsoleAutoComplete', 'main',
	function (data)
		data.response = data.response:trim()

		if #data.response == 0 then
			return
		end

		local args = splitArguments(data.response)
		local completedName, command = hook.autoCompleteCommand(table.remove(args, 1))

		if not completedName then
			return
		end

		if command.autoComplete then
			command.autoComplete(args)
		end

		data.response = serializeCommand(completedName, args)
	end
)

require('main.plugins')