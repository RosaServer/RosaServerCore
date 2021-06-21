---@type Plugin
local mode = ...
mode.name = 'Raw Test'
mode.author = 'jdb'
mode.description = 'An empty world where anything is possible.'

mode.defaultConfig = {
	autoSpawn = true,
	startingMap = 'versus2',
	spawnPoints = {
		round = { 1476, 49.5, 1467 },
		test2 = { 1628, 69.5, 1482 },
		versus = { 1552, 25.5, 1566 },
		versus2 = { 1024, 29.5, 1027 }
	}
}

local mapName

function mode.onEnable (isReload)
	mapName = mode.config.startingMap
	if not isReload then
		server:reset()
	end
end

function mode.onDisable ()
	mapName = nil
end

function mode.hooks.ResetGame ()
	server.type = 20
	server.levelToLoad = mapName
end

function mode.hooks.PostResetGame ()
	server.state = STATE_GAME
	server.time = 600
end

function mode.hooks.ServerSend ()
	for _, ply in ipairs(players.getNonBots()) do
		if not ply.human then
			ply.menuTab = 1
		else
			ply.menuTab = 0
		end
	end
end

function mode.hooks.PostServerSend ()
	for _, ply in ipairs(players.getNonBots()) do
		ply.menuTab = 0
	end
end

local function clickedEnterCity (ply)
	if not ply.human then
		local spawnPoint = Vector(unpack(mode.config.spawnPoints[mapName]))

		ply.suitColor = 1
		ply.tieColor = 8
		ply.model = 1
		if humans.create(spawnPoint, orientations.n, ply) then
			ply:update()
		end
	end
end

function mode.hooks.PlayerActions (ply)
	if not ply.human and mode.config.autoSpawn then
		clickedEnterCity(ply)
	elseif ply.numActions ~= ply.lastNumActions then
		local action = ply:getAction(ply.lastNumActions)

		if action.type == 0 and action.a == 1 and action.b == 1 then
			clickedEnterCity(ply)
			ply.lastNumActions = ply.numActions
		end
	end
end

mode.commands['/map'] = {
	info = 'Change the map.',
	usage = '/map <name>',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param args string[]
	call = function (_, _, args)
		assert(#args >= 1, 'usage')

		assert(mode.config.spawnPoints[args[1]], 'Invalid map')
		mapName = args[1]

		hook.once('Logic', function ()
			server:reset()
		end)
	end
}