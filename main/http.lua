local workers = {}

local callbacks = {}

---@param count integer
local function createWorkers (count)
	for i = 1, count do
		workers[i] = {
			pending = 0,
			thread = Worker.new('main/http.worker.lua')
		}
	end
end

local function getFreeWorker ()
	for _, worker in ipairs(workers) do
		if worker.pending == 0 then
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

---@param method string
---@param scheme string
---@param path string
---@param headers table<string, string>
---@param body? string
---@param contentType? string
---@param callback fun(response?: HTTPResponse)
local function request (method, scheme, path, headers, body, contentType, callback)
	local callbackIndex = getFreeCallbackIndex()
	callbacks[callbackIndex] = callback

	local serialized = ('znssn'):pack(method, callbackIndex, scheme, path, table.numElements(headers))
	for key, value in pairs(headers) do
		serialized = serialized .. ('ss'):pack(key, value)
	end

	if method == 'POST' then
		serialized = serialized .. ('ss'):pack(body, contentType)
	end

	local worker = getFreeWorker()
	worker.thread:sendMessage(serialized)
	worker.pending = worker.pending + 1
end

---@param message string
local function handleMessage (message)
	local callbackIndex, hasResponse, pos = ('ni1'):unpack(message)

	---@type HTTPResponse?
	local res
	if hasResponse == 1 then
		res = {}
		local status, body, numHeaders
		status, body, numHeaders, pos = ('nsn'):unpack(message, pos)
		res.status = status
		res.body = body

		local headers = {}
		for _ = 1, numHeaders do
			local key, value
			key, value, pos = ('ss'):unpack(message, pos)
			headers[key] = value
		end

		res.headers = headers
	end

	callbacks[callbackIndex](res)
	callbacks[callbackIndex] = nil
end

---Send an HTTP(S) GET request asynchronously.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@param callback fun(response?: HTTPResponse) The function to be called when the response is received or there was an error.
function http.get (scheme, path, headers, callback)
	request('GET', scheme, path, headers, nil, nil, callback)
end

---Send an HTTP(S) POST request asynchronously.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@param body string The request body.
---@param contentType string The request body MIME type.
---@param callback fun(response?: HTTPResponse) The function to be called when the response is received or there was an error.
function http.post (scheme, path, headers, body, contentType, callback)
	request('POST', scheme, path, headers, body, contentType, callback)
end

hook.add(
	'ConfigLoaded', 'main.http',
	---@param isReload boolean
	function (isReload)
		if not isReload then
			createWorkers(config.httpThreadCount or 4)
		end
	end
)

hook.add(
	'Logic', 'main.http',
	function ()
		for _, worker in ipairs(workers) do
			if worker.pending ~= 0 then
				while true do
					local message = worker.thread:receiveMessage()
					if not message then
						break
					end

					handleMessage(message)
					worker.pending = worker.pending - 1
				end
			end
		end
	end
)