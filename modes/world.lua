---@type Plugin
local mode = ...
mode.name = 'World'
mode.author = 'Cryptic Sea'

mode:addEnableHandler(function (isReload)
	server.type = TYPE_WORLD
	if not isReload then
		server:reset()
	end
end)