---@type Plugin
local plugin = ...
plugin.name = 'Logs'
plugin.author = 'jdb'
plugin.description = 'Logs a bunch of useful events in the console and in daily files.'

plugin.defaultConfig = {
	-- Writes log lines in Discord code blocks.
	webhookEnabled = false,
	webhookHost = 'https://discord.com',
	webhookPath = '/api/webhooks/xxxxxx/xxxxxx'
}

local json = require 'main.json'

local distanceNames
local cachedLines
local cachedLinesTimer

plugin:addEnableHandler(function ()
	if os.createDirectory('logs') then
		plugin:print('Created logs directory')
	end

	distanceNames = {
		[0] = 'Whisper',
		[1] = 'Talk',
		[2] = 'Yell'
	}
	cachedLines = {}
	cachedLinesTimer = 0
end)

plugin:addDisableHandler(function ()
	distanceNames = nil
	cachedLines = nil
	cachedLinesTimer = nil
end)

---Log an event and keep a permanent record of it.
---@param format string The string or string format to log.
---@vararg any The additional arguments passed to string.format(format, ...)
function log (format, ...)
	if not plugin.isEnabled then return end

	local str = string.format(format, ...)
	plugin:print(str)

	local logLine = '[' .. os.date('%X') .. '] ' .. str
	table.insert(cachedLines, logLine)

	local logFile = io.open('logs/' .. os.date('%Y-%m-%d') .. '.txt', 'a')
	logFile:write(logLine .. '\n')
	logFile:close()
end

local function onResponse (res)
	if plugin.isEnabled and not res then
		plugin:print('Webhook POST failed')
	end
end

do
	local awaitConnected = {}

	plugin:addHook(
		'PostPlayerCreate',
		---@param ply Player
		function (ply)
			awaitConnected[ply.index] = true
		end
	)

	plugin:addHook(
		'PostPlayerDelete',
		---@param ply Player
		function (ply)
			awaitConnected[ply.index] = nil
			if not ply.isBot then
				log('[Exit] %s (%s)', ply.name, dashPhoneNumber(ply.phoneNumber))
			end
		end
	)

	plugin:addHook(
		'Logic',
		function ()
			for index, _ in pairs(awaitConnected) do
				local ply = players[index]
				if ply.isBot then
					awaitConnected[index] = nil
				else
					local con = ply.connection
					if con then
						awaitConnected[index] = nil
						log('[Join] %s (%s) (%s) from %s', ply.name, dashPhoneNumber(ply.phoneNumber), ply.account.steamID, con.address)
					end
				end
			end

			cachedLinesTimer = cachedLinesTimer + 1
			if #cachedLines > 0 and cachedLinesTimer > 10 * server.TPS then
				cachedLinesTimer = 0

				local str = ''
				while #cachedLines > 0 do
					local line = cachedLines[1] .. '\n'
					line = line:gsub('```', '\\`\\`\\`')

					local newStr = str .. line
					if string.len(newStr) > 1800 then
						if #cachedLines == 1 then
							table.remove(cachedLines, 1)
						end
						break
					end

					str = newStr
					table.remove(cachedLines, 1)
				end

				if str ~= '' and plugin.config.webhookEnabled then
					http.post(plugin.config.webhookHost, plugin.config.webhookPath, {}, json.encode({
						content = '```accesslog\n' .. str .. '```',
						username = server.name
					}), 'application/json', onResponse)
				end
			end
		end
	)

	plugin:addHook(
		'EventMessage',
		---@param type integer
		---@param message string
		---@param speakerId integer
		---@param distance integer
		function (type, message, speakerId, distance)
			if speakerId == -1 then return end
			local ply, man

			if type == 0 then
				ply = players[speakerId]
			elseif type == 1 then
				man = humans[speakerId]
				ply = man.player
			else
				return
			end

			if not ply then return end

			if type == 1 then
				log('[Chat][%s] %s (%s): %s', distanceNames[distance], ply.name, dashPhoneNumber(ply.phoneNumber), message)
			else
				log('[Chat][X] %s (%s): %s', ply.name, dashPhoneNumber(ply.phoneNumber), message)
			end
		end
	)
end