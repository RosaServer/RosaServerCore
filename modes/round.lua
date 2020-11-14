local mode = ...
mode.name = 'Round'
mode.author = 'Cryptic Sea'

function mode.onEnable ()
	server.type = TYPE_ROUND
	server:reset()
end