# LuaCommandProcessor

Allows for the registration of custom console commands through the global object named `commands`. Similarly to [event subscriptions](runtime:LuaBootstrap::on_event), these don't persist through a save-and-load cycle.

## Attributes

### commands

Lists the custom commands registered by scripts through `LuaCommandProcessor`.

**Read type:** Dictionary[`string`, `LocalisedString`]

### game_commands

Lists the built-in commands of the core game. The [wiki](https://wiki.factorio.com/Console) has an overview of these.

**Read type:** Dictionary[`string`, `LocalisedString`]

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### add_command

Add a custom console command.

Trying to add a command with the `name` of a game command or the name of a custom command that is already in use will result in an error.

This example command will register a custom event called `print_tick` that prints the current tick to either the player issuing the command or to everyone on the server, depending on the command parameter:

```
commands.add_command("print_tick", nil, function(command)
  if command.player_index ~= nil and command.parameter == "me" then
    game.get_player(command.player_index).print(command.tick)
  else
    game.print(command.tick)
  end
end)
```

This shows the usage of the table that gets passed to any function handling a custom command. This specific example makes use of the `tick` and the optional `player_index` and `parameter` fields. The user is supposed to either call it without any parameter (`"/print_tick"`) or with the `"me"` parameter (`"/print_tick me"`).

**Parameters:**

- `name` `string` - The desired name of the command (case sensitive).
- `help` `LocalisedString` - The localised help message. It will be shown to players using the `/help` command.
- `function` function(`CustomCommandData`) - The function that will be called when this command is invoked.

### remove_command

Remove a custom console command.

**Parameters:**

- `name` `string` - The name of the command to remove (case sensitive).

**Returns:**

- `boolean` - Whether the command was successfully removed. Returns `false` if the command didn't exist.

