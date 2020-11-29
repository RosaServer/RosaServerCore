---@type Plugin
local mode = ...
mode.name = 'Eliminator'
mode.author = 'Cryptic Sea'

function mode.onEnable (isReload)
	server.type = TYPE_TERMINATOR
	if not isReload then
		server:reset()
	end
end