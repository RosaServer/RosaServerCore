require 'main.util'

---@param message string
local function handleMessage (message)
	local method, callbackIndex, scheme, path, numHeaders, pos = ('znssn'):unpack(message)

	local headers = {}
	for _ = 1, numHeaders do
		local key, value
		key, value, pos = ('ss'):unpack(message, pos)
		headers[key] = value
	end

	---@type HTTPResponse?
	local res
	if method == 'POST' then
		local body, contentType = ('ss'):unpack(message, pos)
		res = http.postSync(scheme, path, headers, body, contentType)
	else
		res = http.getSync(scheme, path, headers)
	end

	local serialized = ('ni1'):pack(callbackIndex, res and 1 or 0)

	if res then
		serialized = serialized .. ('nsn'):pack(res.status, res.body, table.numElements(res.headers))
		for key, value in pairs(res.headers) do
			serialized = serialized .. ('ss'):pack(key, value)
		end
	end

	sendMessage(serialized)
end

while true do
	while true do
		local message = receiveMessage()
		if not message then
			break
		end

		handleMessage(message)
	end

	if sleep(100) then
		break
	end
end