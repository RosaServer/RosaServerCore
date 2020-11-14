local mode = ...
mode.name = 'Versus'
mode.author = 'Cryptic Sea'

function mode.onEnable ()
	server.type = TYPE_VERSUS
	server:reset()
end