local mode = ...
mode.name = 'Raw Test'
mode.author = 'jdb'
mode.description = 'An empty world where anything is possible.'

local mapName

mode.onEnable = function ()
	mapName = 'versus2'
	server:reset()
end

mode.onDisable = function ()
	mapName = nil
end

mode.hooks.ResetGame = function (reason)
	server.type = 20
	server.levelToLoad = mapName
end

mode.hooks.SendPacket = function ()
	for _, ply in ipairs(players.getNonBots()) do
		if not ply.human then
			ply.menuTab = 1
		else
			ply.menuTab = 0
		end
	end
end

mode.hooks.PostSendPacket = function ()
	for _, ply in ipairs(players.getNonBots()) do
		ply.menuTab = 0
	end
end

local function clickedEnterCity (ply)
	if not ply.human then
		ply.suitColor = 1
		ply.tieColor = 8
		ply.model = 1
		if humans.create(Vector(1024, 29.5, 1027), orientations.n, ply) then
			ply:update()
		end
	end
end

mode.hooks.PlayerActions = function (ply)
	if ply.numActions ~= ply.lastNumActions then
		local action = ply:getAction(ply.lastNumActions)

		if action.type == 0 and action.a == 1 and action.b == 1 then
			clickedEnterCity(ply)
			ply.lastNumActions = ply.numActions
		end
	end
end

mode.commands['/map'] = {
	info = 'Change the map.',
	usage = '/map <name',
	canCall = function (ply) return ply.isConsole or ply.isAdmin end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function (ply, man, args)
		assert(#args >= 1, 'usage')

		mapName = args[1]

		hook.once('PostPlayerActions', function ()
			server:reset()
		end)
	end
}