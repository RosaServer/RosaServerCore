# RosaServerCore

The standard implementation of RosaServer including a plugin/gamemode system.

Requires [RosaServer](https://github.com/RosaServer/RosaServer).

# Getting Started

## Configuration

Copy `config.sample.lua` to `config.lua` and modify to your heart's content.

## Scripting

The easiest way to start working is to create either a plugin or a gamemode. They work the same, except only one gamemode can be enabled at a time.

## Types

If you use VS Code, you can get IntelliSense working using [this Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).

IntelliJ IDEA also has better support, using [this plugin](https://github.com/EmmyLua/IntelliJ-EmmyLua).

All the RosaServer types/globals are laid out in `.meta/template` for this reason. It's also useful as documentation.

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

### Most Notable Commands

- `/resetlua` - Reset the Lua state and the game.
- `/mode <mode>` - Change the enabled mode.

#### Moderators

- `/mod <phoneNumber/name>` - Add a moderator.
- `/unmod <phoneNumber/name>` - Remove a moderator.

#### Punishment

- `/kick <phoneNumber/name> [reason]` - Kick a player.
- `/punish <phoneNumber/name> [reason]` - Ban an account based on previous bans.
- `/unpunish <phoneNumber/name> [reason]` - Remove a punishment from an account.
- `/ban <phoneNumber/name> <minutes> [reason]` - Ban an account.
- `/unban <phoneNumber/name> [reason]` - Unban an account.
- `/kill <phoneNumber/name>` - Kill a player.

#### Spawning

- `/item <name/id>` - Spawn an item.
- `/car [type] [color]` - Spawn a vehicle.
- `/cash [amount]` - Give yourself money.
- `/give <phoneNumber> <amount>` - Give a player money.
- `/del` - Delete an object you're looking at.

#### Teleportation

- `/find <phoneNumber/name>` - Teleport to a player.
- `/fetch <phoneNumber/name>` - Teleport a player to you.
- `/hide` - Teleport to an inaccessible room.

#### Utility

- `/message <message>` - Announce a message.
- `/say <message>` - Announce a message prepended by (Moderator).
- `/name <name>` - Set the server name.
- `/time <hour/hour:minute>` - Set the solar time.
- `/pos` - Get your current position.
- `/skip` - Skip the round timer.
- `/who <name>` - Search players by name.

#### Warnings

- `/warn <phoneNumber/name> <reason>` - Warn a player.
- `/warned` - Acknowledge a warning.

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

### Most Notable Commands

- `eval <code>` - Evaluate a Lua string.
- `list` - List all current players.
- `list` - List all plugins.
- `enableplugin <plugin>` - Enable a plugin (persists after a restart).
- `disableplugin <plugin>` - Disable a plugin (persists after a restart).
- `listbans` - List all current bans.

## Help

Adds the `/help` command.

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

## Short Chat

Rejects very wide chat messages.

## Shutdown

Adds the `/shutdown [minutes/"now"]` command.

## Title Info

Adds useful information to the console window title.

```lua
plugin.defaultConfig = {
	updateSeconds = 10
}
```

Also, adds the `/tps` command.

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

## Where

Locates players relative to streets.

### Most Notable Commands

- `/where <phoneNumber/name>` - Locate a player.

## Whitelist

Only let in certain players.

```lua
plugin.defaultConfig = {
	-- How many people can be let in regardless of if they're whitelisted
	maxPublicSlots = 0
}
```

### Most Notable Commands

- `listwhitelist` - List all whitelisted players.
- `/whitelist <phoneNumber>` - Add a player to the whitelist.
- `/unwhitelist <phoneNumber>` - Remove a player from the whitelist.
