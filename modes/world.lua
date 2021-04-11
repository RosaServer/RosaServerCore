---@type Plugin
local mode = ...
mode.name = 'World'
mode.author = 'Cryptic Sea'

function mode.onEnable (isReload)
	server.type = TYPE_WORLD
	if not isReload then
		server:reset()
	end
end