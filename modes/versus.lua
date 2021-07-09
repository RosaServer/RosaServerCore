---@type Plugin
local mode = ...
mode.name = 'Versus'
mode.author = 'Cryptic Sea'

mode:addEnableHandler(function (isReload)
	server.type = TYPE_VERSUS
	if not isReload then
		server:reset()
	end
end)