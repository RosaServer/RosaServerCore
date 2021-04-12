local json = require 'main.json'

---@param message string
local function handleMessage (message)
	local data = json.decode(message)

	local res
	if data.method == 'POST' then
		res = http.postSync(data.scheme, data.path, data.headers, data.body, data.contentType)
	else
		res = http.getSync(data.scheme, data.path, data.headers)
	end

	sendMessage(json.encode({
		callback = data.callback,
		res = res
	}))
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