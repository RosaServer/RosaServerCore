---@type Plugin
local mode = ...
mode.name = 'Round'
mode.author = 'Cryptic Sea'

mode:addEnableHandler(function (isReload)
	server.type = TYPE_ROUND
	if not isReload then
		server:reset()
	end
end)