local _hooks = {}
local _tempHooks = {}

local _cache = {}

local CONTINUE = 1
local OVERRIDE = 2

---Stops further hooks of this type from running.
hook.continue = CONTINUE
---Stops further hooks and overrides default game functionality.
hook.override = OVERRIDE

---The currently loaded plugins.
hook.plugins = {}

---Regenerate the cache of enabled hooks.
function hook.resetCache ()
	_cache = {}

	for event, hooks in pairs(_hooks) do
		_cache[event] = {}
		for _, hook in pairs(hooks) do
			table.insert(_cache[event], hook)
		end
	end

	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for event, hook in pairs(plugin.hooks) do
				if _cache[event] == nil then
					_cache[event] = {}
				end
				table.insert(_cache[event], hook)
			end
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
end

---Remove a generic named hook.
---@param eventName string The name of the event to be hooked.
---@param name string The unique name of the hook to remove.
function hook.remove (eventName, name)
	assert(type(eventName) == 'string')
	if _hooks[eventName] == nil then return end

	_hooks[eventName][name] = nil
end

---Run a hook.
---@param eventName string The name of the event.
---@vararg any The arguments to pass to the hook functions.
---@return boolean override Whether default behaviour should be overridden, if applicable.
function hook.run (eventName, ...)
	if _tempHooks[eventName] ~= nil then
		local _tempOverride = false
		for _, tempHookFunc in pairs(_tempHooks[eventName]) do
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
---@return table|nil command The found command, if any.
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

---Run a command.
---@param name string The name of the command being passed.
---@param command table|nil The command to run, usually the result of hook.findCommand.
---@vararg any The rest of the parameters the command expects.
---@see hook.findCommand
function hook.runCommand (name, command, ...)
	if command ~= nil then
		callCommand(name, command, ...)
		return true
	end

	return false
end