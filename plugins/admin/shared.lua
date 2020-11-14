local plugin = ...
local module = {}

local json = require 'main.json'

local function onResponse (res)
	if not res then
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

return module