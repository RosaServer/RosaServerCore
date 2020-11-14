local config = require('config')

if hook.persistentMode == '' then
	hook.persistentMode = config.defaultGameMode
end

---@class Plugin
---@field name string The name of the plugin.
---@field author string The author of the plugin.
---@field description string The description of the plugin.
---@field hooks table
---@field commands table
---@field defaultConfig table
---@field config table
---@field isEnabled boolean
local plugin = {}
plugin.__index = plugin

---Enable safely.
function plugin:enable ()
	if not self.isEnabled then
		self.isEnabled = true
		hook.resetCache()
		self.onEnable()
	end
end

---Disable safely.
function plugin:disable ()
	if self.isEnabled then
		self.isEnabled = false
		self.onDisable()
		hook.resetCache()
	end
end

---Print a message.
---@vararg any The values to print.
function plugin:print (...)
	local color = self.nameSpace == 'modes' and '36;1' or '36'
	printAppend('\27[' .. color .. 'm[' .. self.name .. ']\27[0m ')
	print(...)
end

---Print a warning message.
---@vararg any The values to print.
function plugin:warn (...)
	printAppend('\27[33m[' .. self.name .. ']\27[0m ')
	print(...)
end

---Include another file.
---@param modName string The name of the module to include.
---@return any value The value returned by the file execution.
function plugin:require (modName)
	if not self.requireCache[modName] then
		local fileName = self.nameSpace .. '/' .. self.fileName .. '/' .. modName .. '.lua'
		local loadedFile = assert(loadfile(fileName))
		self.requireCache[modName] = loadedFile(self)
	end

	return self.requireCache[modName]
end

---Indicate the plugin has been enabled.
function plugin:onEnable () end

---Indicate the plugin has been disabled.
function plugin:onDisable () end

local function newPlugin (nameSpace, stem)
	return setmetatable({
		name = 'Unknown',
		author = 'Unknown',
		description = 'n/a',
		hooks = {},
		commands = {},
		defaultConfig = {},
		config = {},
		isEnabled = true,
		requireCache = {},
		nameSpace = nameSpace,
		fileName = stem
	}, plugin)
end

local function loadPlugins (nameSpace, isEnabledFunc)
	print('Loading ' .. nameSpace .. '...')
	local numLoaded = 0

	local entries = os.listDirectory(nameSpace)
	for _, entry in ipairs(entries) do
		if entry.isDirectory or entry.extension == '.lua' then
			local plug = newPlugin(nameSpace, entry.stem)

			local entryPath
			if entry.isDirectory then
				entryPath = nameSpace .. '/' .. entry.stem ..'/init.lua'
			else
				entryPath = nameSpace .. '/' .. entry.name
			end

			local loadedFile = assert(loadfile(entryPath))
			loadedFile(plug)

			hook.plugins[entry.stem] = plug

			-- Load default config
			for k, v in pairs(plug.defaultConfig) do
				plug.config[k] = v
			end

			-- Load config
			local conf = config[nameSpace][entry.stem]
			if conf then
				for k, v in pairs(conf) do
					plug.config[k] = v
				end
			end

			-- Enable
			plug.isEnabled = isEnabledFunc(plug)
			if plug.isEnabled then
				plug.onEnable()
			end

			numLoaded = numLoaded + 1
		end
	end

	print('Loaded ' .. numLoaded .. ' ' .. nameSpace)
end

loadPlugins('plugins', function (plug)
	return true
end)

loadPlugins('modes', function (plug)
	return plug.fileName == hook.persistentMode
end)

hook.resetCache()