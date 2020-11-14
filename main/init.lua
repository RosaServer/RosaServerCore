print('Alpha ' .. server.version .. ', ' .. _VERSION .. ', ' .. jit.version)

math.randomseed(os.time())

require('main.util')
require('main.hook')

local chatCooldowns = {}
local chatCooldownSeconds = 0.5

local function splitArguments (str)
	local args = {}
	local split = str:split(' ')

	local inQuotes = nil
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
	local startPos, endPos = errorString:find(': ')
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
	---@param ply Player
	---@param message string
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
	sendMessage = function (self, ...)
		printAppend('\27[31;1m')
		print(...)
		printAppend('\27[0m')
	end
}

hook.add(
	'ConsoleInput', 'main',
	---@param message string
	function (message)
		local args = splitArguments(message)
		local name = table.remove(args, 1)
		if not name then return end

		-- Commands that don't start with / can only be invoked by the console
		if hook.runCommand(name, hook.findCommand(name), args) then
			return
		end

		if hook.runCommand('/' .. name, hook.findCommand('/' .. name), consolePlayer, nil, args) then
			return
		end

		print('Command "'..name..'" not found!')
	end
)

require('main.plugins')