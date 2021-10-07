math.randomseed(os.time())

require 'main.util'
require 'main.hook'
require 'main.gameUtil'
require 'main.plugins'
require 'main.http'

local yaml = require 'main.yaml'

local hasConfigLoadedOnce = false

---Load config from config.yml.
---@param fileName? string The overloaded file path to load instead of the default file.
function loadConfig (fileName)
	local f = assert(io.open(fileName or 'config.yml', 'r'), 'Could not open config file')
	local contents = f:read('*all')
	f:close()

	config = yaml.parse(contents)

	hook.run('ConfigLoaded', hasConfigLoadedOnce)
	hasConfigLoadedOnce = true
end

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
	local stripped = endPos and errorString:sub(endPos + 1) or errorString

	if stripped == 'usage' then
		local usage = commandName .. (command.usage and (' ' .. command.usage) or '')
		messagePlayerWrap(ply, 'Usage: ' .. usage)
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

	if not ply.isAdmin and command.cooldownTime then
		local now = os.realClock()

		if not ply.data.commandCooldowns then
			ply.data.commandCooldowns = {}
		end
		local cooldowns = ply.data.commandCooldowns

		if cooldowns[command] and now - cooldowns[command] < command.cooldownTime then
			ply:sendMessage(('Error: Please wait %.1fs'):format(command.cooldownTime - (now - cooldowns[command])))
			return hook.override
		end

		cooldowns[command] = now
	end

	local success, result = pcall(hook.runCommand, commandName, command, ply, ply.human, args)
	if not success then
		handleChatCommandError(ply, commandName, command, result)
	end

	return hook.override
end

local chatCooldownSeconds
local consolePlayer = {
	isConsole = true,
	name = '',
	data = {},
	sendMessage = function (_, message)
		print('\27[31;1m' .. message .. '\27[0m')
	end
}

hook.add(
	'ConfigLoaded', 'main',
	function ()
		chatCooldownSeconds = config.chatCooldownSeconds or 0.5
		consolePlayer.name = config.consolePlayerName or 'Console'
	end
)

hook.add(
	'PlayerChat', 'main',
	function (ply, message)
		-- Rate limit chat for non-admins
		if not ply.isAdmin then
			local data = ply.data
			local now = os.realClock()

			if data.chatCooldown and now - data.chatCooldown < chatCooldownSeconds then
				return hook.override
			end

			data.chatCooldown = now
		end

		-- Run Lua commands
		if message:startsWith('/') then
			return attemptChatCommand(ply, message)
		end
	end
)

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

hook.add(
	'InterruptSignal', 'main',
	function ()
		for _, plug in pairs(hook.plugins) do
			plug:disable()
		end
	end
)

loadConfig()