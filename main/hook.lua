local _hooks = {}
local _tempHooks = {}

local _cache = {}

local pairs = pairs
local ipairs = ipairs

local CONTINUE = 1
local OVERRIDE = 2

---Stops further hooks of this type from running.
hook.continue = CONTINUE
---Stops further hooks and overrides default game functionality.
hook.override = OVERRIDE

---The currently loaded plugins.
---@type table<string, Plugin>
hook.plugins = {}

---Regenerate the cache of enabled hooks.
function hook.resetCache ()
	hook.clear()
	_cache = {}

	local enable = hook.enable

	for event, funcs in pairs(_hooks) do
		enable(event)
		_cache[event] = {}
		for _, func in pairs(funcs) do
			table.insert(_cache[event], func)
		end
	end

	local sortingHooks = {}

	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for event, func in pairs(plugin.hooks) do
				if _cache[event] == nil then
					enable(event)
					_cache[event] = {}
				end
				table.insert(_cache[event], func)
			end

			for event, infos in pairs(plugin.polyHooks) do
				if sortingHooks[event] == nil then
					sortingHooks[event] = {}
				end

				for _, info in ipairs(infos) do
					table.insert(sortingHooks[event], info)
				end
			end
		end
	end

	for event, infos in pairs(sortingHooks) do
		if _cache[event] == nil then
			enable(event)
			_cache[event] = {}
		end

		table.sort(infos, function (a, b)
			return a.priority < b.priority
		end)

		for _, info in ipairs(infos) do
			table.insert(_cache[event], info.func)
		end
	end
end

---Add a generic named hook.
---@param eventName string The name of the event to be hooked.
---@param name string The unique name of the new hook.
---@param func function The function to be called when the hook runs.
function hook.add (eventName, name, func)
	assert(type(eventName) == 'string')
	assert(type(func) == 'function')

	if _hooks[eventName] == nil then
		_hooks[eventName] = {}
	end

	_hooks[eventName][name] = func
	hook.resetCache()
end

---Add a generic hook to be run once.
---@param eventName string The name of the event to be hooked.
---@param func function The function to be called once when the hook runs.
function hook.once (eventName, func)
	assert(type(eventName) == 'string')
	assert(type(func) == 'function')

	if _tempHooks[eventName] == nil then
		_tempHooks[eventName] = {}
	end

	table.insert(_tempHooks[eventName], func)
	hook.enable(eventName)
end

---Remove a generic named hook.
---@param eventName string The name of the event to be hooked.
---@param name string The unique name of the hook to remove.
function hook.remove (eventName, name)
	assert(type(eventName) == 'string')
	if _hooks[eventName] == nil then return end

	_hooks[eventName][name] = nil
	hook.resetCache()
end

---Run a hook.
---@param eventName string The name of the event.
---@vararg any The arguments to pass to the hook functions.
---@return boolean override Whether default behaviour should be overridden, if applicable.
function hook.run (eventName, ...)
	local hadTemp = false

	if _tempHooks[eventName] ~= nil then
		local _tempOverride = false
		for _, tempHookFunc in ipairs(_tempHooks[eventName]) do
			local isOverride = tempHookFunc(...)

			if isOverride then
				_tempOverride = true
				break
			end
		end
		_tempHooks[eventName] = nil
		if _tempOverride then
			return true
		end
		hadTemp = true
	end

	local cache = _cache[eventName]
	if cache ~= nil then
		for _, hook in pairs(cache) do
			local res = hook(...)

			if res == CONTINUE then
				return false
			end
			if res == OVERRIDE then
				return true
			end
		end
	elseif hadTemp then
		hook.disable(eventName)
	end

	return false
end

---Check whether someone is allowed to run a command.
---@param name string The name of the command.
---@param command table The command table.
---@param plyOrArgs Player|table The calling player, or a table of arguments if it is a console command.
---@return boolean canCall Whether the command can be called given the conditions.
function hook.canCallCommand (name, command, plyOrArgs)
	if not name:startsWith('/') then
		-- This is a console-only command
		return type(plyOrArgs) == 'table'
	else
		if command.canCall then
			return not not command.canCall(plyOrArgs)
		else
			return true
		end
	end
end

local function callCommand (name, command, plyOrArgs, ...)
	if not hook.canCallCommand(name, command, plyOrArgs) then
		error('Access denied')
	end

	command.call(plyOrArgs, ...)
end

---Get all enabled commands.
---@return table commands The name of each command mapped to their command table.
function hook.getCommands ()
	local commands = {}

	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, command in pairs(plugin.commands) do
				commands[name] = command
			end
		end
	end

	return commands
end

---Find a command by its name or alias.
---@param name string The name or alias of the command to find.
---@return table? command The found command, if any.
function hook.findCommand (name)
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			local command = plugin.commands[name]
			if command then
				return command
			end

			for _, c in pairs(plugin.commands) do
				if c.alias and table.contains(c.alias, name) then
					return c
				end
			end
		end
	end

	return nil
end

local function commandNameStartsWith (name, beginning)
	if name:startsWith(beginning) then
		return true
	end

	if name:startsWith('/') then
		return name:sub(2):startsWith(beginning)
	end

	return false
end

---Auto complete a command by its name or alias.
---@param beginning string The name to auto complete.
---@return string? name The full name of the found command, if any.
---@return table? command The found command, if any.
function hook.autoCompleteCommand (beginning)
	--- Check raw names first
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, c in pairs(plugin.commands) do
				if commandNameStartsWith(name, beginning) then
					return name, c
				end
			end
		end
	end

	--- Check aliases, auto complete with raw name anyway
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, c in pairs(plugin.commands) do
				if c.alias then
					for _, alias in ipairs(c.alias) do
						if commandNameStartsWith(alias, beginning) then
							return name, c
						end
					end
				end
			end
		end
	end

	return nil, nil
end

---Auto complete a plugin by its file name or alias.
---@param beginning string The name to auto complete.
---@param nameSpace string? The plugin name space to limit the search to.
---@return string? name The full file name of the found plugin, if any.
---@return Plugin? plugin The found plugin, if any.
function hook.autoCompletePlugin (beginning, nameSpace)
	beginning = beginning:lower()

	for _, plugin in pairs(hook.plugins) do
		if (not nameSpace or plugin.nameSpace == nameSpace) and plugin.fileName:lower():startsWith(beginning) then
			return plugin.fileName, plugin
		end
	end

	return nil, nil
end

---Find a plugin by its file name.
---@param name string The name of the desired plugin.
---@param nameSpace string? The plugin name space to limit the search to.
---@return Plugin? plugin The found plugin, if any.
function hook.getPluginByName (name, nameSpace)
	name = name:lower()

	for _, plugin in pairs(hook.plugins) do
		if (not nameSpace or plugin.nameSpace == nameSpace) and plugin.fileName:lower() == name then
			return plugin
		end
	end

	return nil
end

---Run a command.
---@param name string The name of the command being passed.
---@param command table? The command to run, usually the result of hook.findCommand.
---@vararg any The rest of the parameters the command expects.
---@see hook.findCommand
function hook.runCommand (name, command, ...)
	if command ~= nil then
		callCommand(name, command, ...)
		return true
	end

	return false
end