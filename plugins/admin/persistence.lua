local plugin = ...
local module = {}

local json = require 'main.json'

local persistentData
local persistenceFile = 'admin-persistence.json'

function module.get ()
	return persistentData
end

function module.save ()
	local f = io.open(persistenceFile, 'w')
	if f then
		f:write(json.encode(persistentData))
		f:close()
		plugin:print('Saved persistence')
	end
end

function module.load ()
	local f = io.open(persistenceFile, 'r')
	if f then
		local data = json.decode(f:read('*all'))
		persistentData.moderators = data.moderators or {}
		persistentData.punishments = data.punishments or {}
		persistentData.warnings = data.warnings or {}

		f:close()
		plugin:print('Loaded persistence')
	end
end

function module.onEnable ()
	persistentData = {
		moderators = {},
		punishments = {},
		warnings = {}
	}

	module.load()
end

function module.onDisable ()
	module.save()
	persistentData = nil
end

return module