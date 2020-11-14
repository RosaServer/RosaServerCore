# RosaServerCore

The standard implementation of RosaServer including a plugin/gamemode system.

Requires [RosaServer](https://github.com/RosaServer/RosaServer).

# Getting Started

## Configuration

Copy `config.sample.lua` to `config.lua` and modify to your heart's content.

## Scripting

The easiest way to start working is to create either a plugin or a gamemode. They work the same, except only one gamemode can be enabled at a time.

## Types

If you use VS Code, you can get IntelliSense working using [this Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua). All of the RosaServer types/globals are laid out in `.meta/template` for this reason. It's also useful as documentation.

# Standard Plugins

## Admin

Useful commands for server administrators, with logs.

```lua
plugin.defaultConfig = {
	-- Logs admin actions in Discord rich embeds.
	webhookEnabled = false,
	webhookHost = 'https://discord.com',
	webhookPath = '/api/webhooks/xxxxxx/xxxxxx'
}
```

## Ban Messages

Adds more useful ban messages.

```lua
plugin.defaultConfig = {
	formatString = 'You are still banned for %im!',
	permaFormatString = 'You are permanently banned!'
}
```

## Console Commands

Adds some useful console commands.

## Help

Adds the /help command.

## Logs

Logs a bunch of useful events in the console and in daily files.

```lua
plugin.defaultConfig = {
	-- Writes log lines in Discord code blocks.
	webhookEnabled = false,
	webhookHost = 'https://discord.com',
	webhookPath = '/api/webhooks/xxxxxx/xxxxxx'
}
```

## Shutdown

Adds the /shutdown command.

## Title Info

Adds useful information to the console window title.

```lua
plugin.defaultConfig = {
	updateSeconds = 10
}
```

## Web Uploader

Streams player info to a web server.

```lua
plugin.defaultConfig = {
	host = 'https://oxs.international',
	path = '/api/v1/players',
	-- Seconds allowed between requests even if nothing has changed (default 10 min)
	maximumWaitTime = 10 * 60
}
```
