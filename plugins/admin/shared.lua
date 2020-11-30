---@type Plugin
local plugin = ...
local module = {}

local json = require 'main.json'

local function onResponse (res)
	if plugin.isEnabled and not res then
		plugin:print('Webhook POST failed')
	end
end

function module.discordEmbed (embed)
	if not plugin.config.webhookEnabled then return end

	if not embed.author then
		embed.author = {
			name = '💼 ' .. server.name
		}
	end

	http.post(
		plugin.config.webhookHost,
		plugin.config.webhookPath,
		{},
		json.encode({ embeds = { embed } }),
		'application/json',
		onResponse
	)
end

---@param args string[]
function module.autoCompleteAccountFirstArg (args)
	if #args < 1 then return end

	local result = autoCompleteAccount(args[1])
	if result then
		args[1] = result
	end
end

---@param args string[]
function module.autoCompletePlayerFirstArg (args)
	if #args < 1 then return end

	local result = autoCompletePlayer(args[1])
	if result then
		args[1] = result
	end
end

return module