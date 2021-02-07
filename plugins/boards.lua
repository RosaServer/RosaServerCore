---@type Plugin
local plugin = ...
plugin.name = 'Boards'
plugin.author = 'jdb'
plugin.description = 'Adds hooks for posting "boards" to a web server on reset.'

plugin.defaultConfig = {
	host = 'https://oxs.international',
	path = '/api/v1/boards'
}

local json = require 'main.json'

local function onResponse (res)
	if not plugin.isEnabled then return end

	if not res then
		plugin:print('Request failed')
		return
	end

	if res.status < 200 or res.status > 299 then
		plugin:warn('Error ' .. res.status .. ': ' .. res.body)
		return
	end

	plugin:print('Posted')
end

---Build and post boards to a web server.
function postBoards ()
	local boards = {}

	if hook.run('BuildBoards', boards) then
		return
	end

	local postString

	if #boards == 0 then
		postString = ('{"port":%i,"boards":null}'):format(server.port)
	else
		local body = {
			port = server.port,
			boards = boards
		}

		postString = json.encode(body)
	end

	local cfg = plugin.config
	http.post(cfg.host, cfg.path, {}, postString, 'application/json', onResponse)
end

plugin.hooks.PostResetGame = postBoards