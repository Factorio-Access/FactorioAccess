# LuaHelpers

Provides various helper and utility functions. It is accessible through the global object named `helpers` in all stages (settings, prototype and runtime).

## Methods

### check_prototype_translations

Goes over all items, entities, tiles, recipes, technologies among other things and logs if the locale is incorrect.

Also prints true/false if called from the console.

Not available in settings and prototype stages.

### compare_versions

Compares 2 version strings.

**Parameters:**

- `first` `string`: First version string to compare.
- `second` `string`: Second version string to compare.

**Returns:**

- `int`: -1 if first is smaller than second, 0 if first equal second, 1 if first is greater than second.

### create_profiler

Creates a [LuaProfiler](runtime:LuaProfiler), which is used for measuring script performance.

LuaProfiler cannot be serialized.

Not available in settings and prototype stages.

**Parameters:**

- `stopped` `boolean` _(optional)_: Create the timer stopped

**Returns:**

- `LuaProfiler`: 

### decode_string

Base64 decodes and inflates the given string.

**Parameters:**

- `string` `string`: The string to decode.

**Returns:**

- `string`: The decoded string or `nil` if the decode failed.

### direction_to_string

Converts the given direction into the string version of the direction.

**Parameters:**

- `direction` `defines.direction`: 

**Returns:**

- `string`: 

### encode_string

Deflates and base64 encodes the given string.

**Parameters:**

- `string` `string`: The string to encode.

**Returns:**

- `string`: The encoded string or `nil` if the encode failed.

### evaluate_expression

Evaluate an expression, substituting variables as provided.

**Parameters:**

- `expression` `MathExpression`: The expression to evaluate.
- `variables` `dictionary<`string`, `double`>` _(optional)_: Variables to be substituted.

**Returns:**

- `double`: 

### is_valid_sound_path

Checks if the given SoundPath is valid.

Not available in settings and prototype stages.

**Parameters:**

- `sound_path` `SoundPath`: Path to the sound.

**Returns:**

- `boolean`: 

### is_valid_sprite_path

Checks if the given SpritePath is valid and contains a loaded sprite. The existence of the image is not checked for paths of type `file`.

Not available in settings and prototype stages.

**Parameters:**

- `sprite_path` `SpritePath`: Path to the image.

**Returns:**

- `boolean`: 

### json_to_table

Convert a JSON string to a table.

**Parameters:**

- `json` `string`: The string to convert.

**Returns:**

- `AnyBasic`: The returned object, or `nil` if the JSON string was invalid.

### parse_map_exchange_string

Convert a map exchange string to map gen settings and map settings.

Not available in settings and prototype stages.

**Parameters:**

- `map_exchange_string` `string`: 

**Returns:**

- `MapExchangeStringData`: 

### remove_path

Remove a file or directory in the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). Can be used to remove files created by [LuaHelpers::write_file](runtime:LuaHelpers::write_file).

**Parameters:**

- `path` `string`: The path to the file or directory to remove, relative to `script-output`.

### table_to_json

Convert a table to a JSON string

**Parameters:**

- `data` `table`: 

**Returns:**

- `string`: 

### write_file

Write a file to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name and file extension of the file can be specified via the `filename` parameter.

**Parameters:**

- `append` `boolean` _(optional)_: If `true`, `data` will be appended to the end of the file. Defaults to `false`, which will overwrite any pre-existing file with the new `data`.
- `data` `LocalisedString`: The content to write to the file.
- `filename` `string`: The name of the file. Providing a directory path (ex. `"save/here/example.txt"`) will create the necessary folder structure in `script-output`.
- `for_player` `uint` _(optional)_: If given, the file will only be written for this `player_index`. Providing `0` will only write to the server's output if present. `for_player` cannot be used in settings and prototype stages.

## Attributes

### game_version

**Type:** `string` _(read-only)_

Current version of game

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

