# LuaHelpers

Provides various helper and utility functions. It is accessible through the global object named `helpers` in all stages (settings, prototype and runtime).

## Attributes

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

### game_version

Current version of game

**Read type:** `string`

## Methods

### table_to_json

Convert a table to a JSON string

**Parameters:**

- `data` `table`

**Returns:**

- `string`

### json_to_table

Convert a JSON string to a table.

**Parameters:**

- `json` `string` - The string to convert.

**Returns:**

- `AnyBasic` *(optional)* - The returned object, or `nil` if the JSON string was invalid.

### write_file

Write a file to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name and file extension of the file can be specified via the `filename` parameter.

**Parameters:**

- `append` `boolean` *(optional)* - If `true`, `data` will be appended to the end of the file. Defaults to `false`, which will overwrite any pre-existing file with the new `data`.
- `data` `LocalisedString` - The content to write to the file.
- `filename` `string` - The name of the file. Providing a directory path (ex. `"save/here/example.txt"`) will create the necessary folder structure in `script-output`.
- `for_player` `uint` *(optional)* - If given, the file will only be written for this `player_index`. Providing `0` will only write to the server's output if present. `for_player` cannot be used in settings and prototype stages.

### send_udp

Send data to a UDP port on localhost for a specified player, if enabled.

This must be enabled per-instance with `--enable-lua-udp`.

**Parameters:**

- `data` `LocalisedString` - The content to send.
- `for_player` `uint` *(optional)* - If given, the packet will only be sent from this `player_index`. Providing `0` will only send from the server if present. `for_player` cannot be used in settings and prototype stages.
- `port` `uint16` - Destination port number (localhost only)

### recv_udp

Dispatch [defines.events.on_udp_packet_received](runtime:defines.events.on_udp_packet_received) events for any new packets received by the specified player or the server.

This must be enabled per-instance with `--enable-lua-udp`.

UDP socket when enabled requests 256KB of receive buffer from the operating system. If there is more data than this between two subsequent calls of this method, data will be lost. That also applies to periods when the game is paused or is being saved as in those case the game update is not happening.

Note: lua event is not raised immediately as the UDP packet needs to be introduced into game state by means of input actions. Please keep incoming traffic as small as possible as in case of multiplayer game with many players, all this data will have to go through the multiplayer server and be distributed to all clients.

Not available in settings and prototype stages.

**Parameters:**

- `for_player` `uint` *(optional)* - If given, packets will only be read from this `player_index`. Providing `0` will only read from the server if present.

### remove_path

Remove a file or directory in the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). Can be used to remove files created by [LuaHelpers::write_file](runtime:LuaHelpers::write_file).

**Parameters:**

- `path` `string` - The path to the file or directory to remove, relative to `script-output`.

### direction_to_string

Converts the given direction into the string version of the direction.

**Parameters:**

- `direction` `defines.direction`

**Returns:**

- `string`

### evaluate_expression

Evaluate an expression, substituting variables as provided.

**Parameters:**

- `expression` `MathExpression` - The expression to evaluate.
- `variables` Dictionary[`string`, `double`] *(optional)* - Variables to be substituted.

**Returns:**

- `double`

**Examples:**

```
-- Calculate the number of research units required to unlock mining productivity level 10
local formula = game.forces["player"].technologies["mining-productivity-4"].research_unit_count_formula
local units = helpers.evaluate_expression(formula, { L = 10, l = 10 })
```

### encode_string

Deflates and base64 encodes the given string.

**Parameters:**

- `string` `string` - The string to encode.

**Returns:**

- `string` *(optional)* - The encoded string or `nil` if the encode failed.

### decode_string

Base64 decodes and inflates the given string.

**Parameters:**

- `string` `string` - The string to decode.

**Returns:**

- `string` *(optional)* - The decoded string or `nil` if the decode failed.

### parse_map_exchange_string

Convert a map exchange string to map gen settings and map settings.

Not available in settings and prototype stages.

**Parameters:**

- `map_exchange_string` `string`

**Returns:**

- `MapExchangeStringData`

### check_prototype_translations

Goes over all items, entities, tiles, recipes, technologies among other things and logs if the locale is incorrect.

Also prints true/false if called from the console.

Not available in settings and prototype stages.

### is_valid_sound_path

Checks if the given SoundPath is valid.

Not available in settings and prototype stages.

**Parameters:**

- `sound_path` `SoundPath` - Path to the sound.

**Returns:**

- `boolean`

### is_valid_sprite_path

Checks if the given SpritePath is valid and contains a loaded sprite. The existence of the image is not checked for paths of type `file`.

Not available in settings and prototype stages.

**Parameters:**

- `sprite_path` `SpritePath` - Path to the image.

**Returns:**

- `boolean`

### create_profiler

Creates a [LuaProfiler](runtime:LuaProfiler), which is used for measuring script performance.

LuaProfiler cannot be serialized.

Not available in settings and prototype stages.

**Parameters:**

- `stopped` `boolean` *(optional)* - Create the timer stopped

**Returns:**

- `LuaProfiler`

### compare_versions

Compares 2 version strings.

**Parameters:**

- `first` `string` - First version string to compare.
- `second` `string` - Second version string to compare.

**Returns:**

- `int` - -1 if first is smaller than second, 0 if first equal second, 1 if first is greater than second.

