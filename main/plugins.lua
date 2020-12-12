local json = require 'main.json'

local doPrintsWithoutTime

local function getTimePrefix ()
	if doPrintsWithoutTime then
		return ''
	end

	return '\27[30;1m[' .. os.date('%X') .. ']\27[0m '
end

local function printScoped (...)
	local prefix = '\27[34m[Plugins]\27[0m '
	print(getTimePrefix() .. prefix .. concatVarArgs('\t', ...))
end

local disabledPluginsFile = 'disabledPlugins.json'

local disabledPluginsMap = {}
do
	local f = io.open(disabledPluginsFile, 'r')
	if f then
		local array = json.decode(f:read('*all'))
		for _, name in ipairs(array) do
			disabledPluginsMap[name] = true
		end

		f:close()
	end
end

local function saveDisabledPlugins ()
	local f = io.open(disabledPluginsFile, 'w')
	if f then
		local array = {}
		for name, _ in pairs(disabledPluginsMap) do
			table.insert(array, name)
		end

		if #array == 0 then
			f:close()
			if os.remove(disabledPluginsFile) then
				printScoped('Removed ' .. disabledPluginsFile)
			end
		else
			f:write(json.encode(array))
			f:close()
			printScoped('Exported to ' .. disabledPluginsFile)
		end
	end
end

---@class Command
---@field info string What the command does.
---@field usage string? How to use the command.
---@field alias string[]? Aliases of the command.
---@field canCall fun(player: Player)?: boolean Function which checks whether a player can call this command.
---@field autoComplete fun(args: string[])? Function which manipulates arguments when pressing tab in the terminal.
---@field call fun(player: Player, human?: Human, args: string[]) Calls the command.
---@field cooldownTime number? How many seconds a player has to wait before using the command again.

---@class Plugin
---@field name string The name of the plugin.
---@field author string The author of the plugin.
---@field description string The description of the plugin.
---@field hooks table<string, function>
---@field commands table<string, Command>
---@field defaultConfig table
---@field config table
---@field isEnabled boolean
local plugin = {}
plugin.__index = plugin

---Enable safely.
---@param shouldSave boolean? Whether to persist the plugin being enabled and save disabled plugins to disk.
function plugin:enable (shouldSave)
	if not self.isEnabled then
		self.isEnabled = true
		hook.resetCache()
		self.onEnable(false)

		if shouldSave then
			disabledPluginsMap[self.fileName] = nil
			saveDisabledPlugins()
		end
	end
end

---Disable safely.
---@param shouldSave boolean? Whether to persist the plugin being disabled and save disabled plugins to disk.
function plugin:disable (shouldSave)
	if self.isEnabled then
		self.isEnabled = false
		self.onDisable(false)
		hook.resetCache()

		if shouldSave then
			disabledPluginsMap[self.fileName] = true
			saveDisabledPlugins()
		end
	end
end

local acceptableColors = {}
do
	local i = 0
	for color = 17, 230 do
		if (color % 6 < 4) then
			i = i + 1
			acceptableColors[i] = color
		end
	end
end

---@param name string
local function nameToColor (name)
	local sum = 0

	for i = 1, #name do
		sum = sum + name:byte(i) * 17
	end

	return acceptableColors[sum % #acceptableColors + 1]
end

---Print a message.
---@vararg any The values to print.
function plugin:print (...)
	if not self._printColor then
		self._printColor = nameToColor(self.name)
	end

	local color = self.nameSpace == 'modes' and 248 or self._printColor
	local prefix = '\27[38;5;' .. color .. 'm[' .. self.name .. ']\27[0m '
	print(getTimePrefix() .. prefix .. concatVarArgs('\t', ...))
end

---Print a warning message.
---@vararg any The values to print.
function plugin:warn (...)
	local prefix = '\27[33m[' .. self.name .. ']\27[0m '
	print(getTimePrefix() .. prefix .. concatVarArgs('\t', ...))
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

---Add a hook, where multiple hooks can be for the same event.
---@param eventName string The name of the event to be hooked.
---@param func function The function to be called when the hook runs.
function plugin:addHook (eventName, func)
	if not self.polyHooks[eventName] then
		self.polyHooks[eventName] = {}
	end

	table.insert(self.polyHooks[eventName], func)
end

function plugin:setConfig ()
	self.config = {}

	-- Load default config
	for k, v in pairs(self.defaultConfig) do
		self.config[k] = v
	end

	-- Load config
	local conf = config[self.nameSpace][self.fileName]
	if conf then
		for k, v in pairs(conf) do
			self.config[k] = v
		end
	end
end

function plugin:load (isEnabled, isReload)
	local loadedFile = assert(loadfile(self.entryPath))

	loadedFile(self)
	self:setConfig()

	-- Mark as enabled
	self.isEnabled = isEnabled
	if self.isEnabled then
		self.onEnable(isReload)
	end
end

function plugin:reload ()
	local isEnabled = self.isEnabled

	if isEnabled then
		self:onDisable(true)
	end

	hook.resetCache()

	self.requireCache = {}
	self:load(isEnabled, true)

	hook.resetCache()
end

---Indicate the plugin has been enabled.
---@param isReload boolean
function plugin:onEnable (isReload) end

---Indicate the plugin has been disabled.
---@param isReload boolean
function plugin:onDisable (isReload) end

local function newPlugin (nameSpace, stem)
	return setmetatable({
		name = 'Unknown',
		author = 'Unknown',
		description = 'n/a',
		hooks = {},
		polyHooks = {},
		commands = {},
		defaultConfig = {},
		config = {},
		isEnabled = true,
		requireCache = {},
		nameSpace = nameSpace,
		fileName = stem
	}, plugin)
end

local function loadPluginNameSpace (nameSpace, isEnabledFunc)
	printScoped('Loading ' .. nameSpace .. '...')
	local numLoaded = 0

	local entries = os.listDirectory(nameSpace)
	for _, entry in ipairs(entries) do
		if entry.isDirectory or entry.extension == '.lua' then
			local plug = newPlugin(nameSpace, entry.stem)

			if entry.isDirectory then
				plug.entryPath = nameSpace .. '/' .. entry.stem ..'/init.lua'
			else
				plug.entryPath = nameSpace .. '/' .. entry.name
			end

			hook.plugins[entry.stem] = plug

			local isEnabled = isEnabledFunc(plug)

			printScoped(string.format('Loading \27[30;1m%s.\27[0m%s', nameSpace, entry.stem))
			plug:load(isEnabled, false)

			numLoaded = numLoaded + 1
		end
	end

	printScoped('Loaded ' .. numLoaded .. ' ' .. nameSpace)
end

local function loadPlugins ()
	if hook.persistentMode == '' then
		hook.persistentMode = config.defaultGameMode
	end

	loadPluginNameSpace('plugins', function (plug)
		return not disabledPluginsMap[plug.fileName]
	end)

	loadPluginNameSpace('modes', function (plug)
		return plug.fileName == hook.persistentMode
	end)

	hook.resetCache()
end

local function reloadConfigOfPlugins ()
	for _, plugs in pairs(hook.plugins) do
		for _, plug in pairs(plugs) do
			plug:setConfig()
		end
	end
end

hook.add(
	'ConfigLoaded', 'main.plugins',
	---@param isReload boolean
	function (isReload)
		doPrintsWithoutTime = config.doPrintsWithoutTime

		if not isReload then
			loadPlugins()
		else
			reloadConfigOfPlugins()
		end
	end
)