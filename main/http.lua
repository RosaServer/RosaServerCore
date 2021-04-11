local json = require 'main.json'

local workers = {}

local callbacks = {}

---@param count integer
local function createWorkers (count)
	for i = 1, count do
		workers[i] = {
			pending = false,
			thread = Worker.new('main/http.worker.lua')
		}
	end
end

local function getFreeWorker ()
	for _, worker in ipairs(workers) do
		if not worker.pending then
			return worker
		end
	end

	return workers[math.random(#workers)]
end

local function getFreeCallbackIndex ()
	local callbackIndex = 1
	while callbacks[callbackIndex] do
		callbackIndex = callbackIndex + 1
	end
	return callbackIndex
end

---@param data table
---@param callback fun(response?: HTTPResponse)
local function request (data, callback)
	local callbackIndex = getFreeCallbackIndex()
	callbacks[callbackIndex] = callback
	data.callback = callbackIndex

	local worker = getFreeWorker()
	worker.thread:sendMessage(json.encode(data))
	worker.pending = true
end

---@param message string
local function handleMessage (message)
	local data = json.decode(message)
	callbacks[data.callback](data.res or nil)
	callbacks[data.callback] = nil
end

---Send an HTTP(S) GET request asynchronously.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@param callback fun(response?: HTTPResponse) The function to be called when the response is received or there was an error.
function http.get(scheme, path, headers, callback)
	request({
		method = 'GET',
		scheme = scheme,
		path = path,
		headers = headers
	}, callback)
end

---Send an HTTP(S) POST request asynchronously.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@param body string The request body.
---@param contentType string The request body MIME type.
---@param callback fun(response?: HTTPResponse) The function to be called when the response is received or there was an error.
function http.post(scheme, path, headers, body, contentType, callback)
	request({
		method = 'POST',
		scheme = scheme,
		path = path,
		headers = headers,
		body = body,
		contentType = contentType
	}, callback)
end

hook.add(
	'ConfigLoaded', 'main.http',
	---@param isReload boolean
	function (isReload)
		if not isReload then
			createWorkers(config.httpThreadCount or 2)
		end
	end
)

hook.add(
	'Logic', 'main.http',
	function ()
		for _, worker in ipairs(workers) do
			if worker.pending then
				while true do
					local message = worker.thread:receiveMessage()
					if not message then
						break
					end

					handleMessage(message)
					worker.pending = false
				end
			end
		end
	end
)