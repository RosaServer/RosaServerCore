---@type Plugin
local mode = ...
mode.name = 'Versus'
mode.author = 'Cryptic Sea'

function mode.onEnable (isReload)
	server.type = TYPE_VERSUS
	if not isReload then
		server:reset()
	end
end