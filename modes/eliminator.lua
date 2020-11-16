---@type Plugin
local mode = ...
mode.name = 'Eliminator'
mode.author = 'Cryptic Sea'

function mode.onEnable ()
	server.type = TYPE_TERMINATOR
	server:reset()
end