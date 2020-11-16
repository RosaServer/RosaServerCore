---@type Plugin
local mode = ...
mode.name = 'World'
mode.author = 'Cryptic Sea'

function mode.onEnable ()
	server.type = TYPE_WORLD
	server:reset()
end