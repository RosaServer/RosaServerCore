---@type Plugin
local mode = ...
mode.name = 'Eliminator'
mode.author = 'Cryptic Sea'

mode:addEnableHandler(function (isReload)
	server.type = TYPE_TERMINATOR
	if not isReload then
		server:reset()
	end
end)