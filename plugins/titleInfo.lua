local plugin = ...
plugin.name = 'Title Info'
plugin.author = 'jdb'
plugin.description = 'Adds useful information to the console window title.'

plugin.defaultConfig = {
	updateSeconds = 10
}

-- calculate TPS every 100 ticks
local sampleInterval = 100
local expFiveSec = 1 / math.exp((16 * sampleInterval) / 5000)
local expOne = 1 / math.exp((16 * sampleInterval) / 60000)
local expFive = 1 / math.exp((16 * sampleInterval) / 300000)
local expFifteen = 1 / math.exp((16 * sampleInterval) / 900000)

local sampleCounter
local lastSampleTime
local recentFiveSec
local recentOne
local recentFive
local recentFifteen

local infoInterval
local infoCounter

function plugin.onEnable ()
	sampleCounter = 0
	lastSampleTime = os.clock()
	recentFiveSec = 62.5
	recentOne = 62.5
	recentFive = 62.5
	recentFifteen = 62.5

	infoInterval = plugin.config.updateSeconds * server.TPS
	infoCounter = 0
end

function plugin.onDisable ()
	sampleCounter = nil
	lastSampleTime = nil
	recentFiveSec = nil
	recentOne = nil
	recentFive = nil
	recentFifteen = nil

	infoInterval = nil
	infoCounter = nil
end

local function calcTPS (avg, exp, tps)
	return (avg * exp) + (tps * (1 - exp))
end

function plugin.hooks.Logic ()
	sampleCounter = sampleCounter + 1
	if sampleCounter == sampleInterval then
		sampleCounter = 0

		local now = os.clock()
		local tps = 1 / (now - lastSampleTime) * sampleInterval

		recentFiveSec = calcTPS(recentFiveSec, expFiveSec, tps)
		recentOne = calcTPS(recentOne, expOne, tps)
		recentFive = calcTPS(recentFive, expFive, tps)
		recentFifteen = calcTPS(recentFifteen, expFifteen, tps)

		lastSampleTime = now
	end

	infoCounter = infoCounter + 1
	if infoCounter == infoInterval then
		infoCounter = 0

		local numPlayers = #players.getNonBots()
		server:setConsoleTitle(string.format('%s | %i player%s | %.2f TPS (%.2f%%)', server.name, numPlayers, numPlayers == 1 and '' or 's', recentOne, recentOne / 62.5 * 100))

		if recentFiveSec < 50 then
			plugin:warn('Tickrate dipped to ' .. recentFiveSec)
			hook.run('TPSDipped', recentFiveSec)
		end
	end
end

plugin.commands['/tps'] = {
	info = "Check the server's TPS.",
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		ply:sendMessage(string.format('TPS from last 5s, 1m, 5m, 15m: %.2f, %.2f, %.2f, %.2f', recentFiveSec, recentOne, recentFive, recentFifteen))
	end
}