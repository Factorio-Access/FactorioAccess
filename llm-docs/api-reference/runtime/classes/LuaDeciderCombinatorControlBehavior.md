# LuaDeciderCombinatorControlBehavior

Control behavior for decider combinators.

**Parent:** [LuaCombinatorControlBehavior](LuaCombinatorControlBehavior.md)

## Attributes

### parameters

This decider combinator's parameters. Writing `nil` clears the combinator's parameters.

**Read type:** `DeciderCombinatorParameters`

**Write type:** `DeciderCombinatorParameters`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_condition

Gets the condition at `index`.

**Parameters:**

- `index` `uint32` - Index of condition to get.

**Returns:**

- `DeciderCombinatorCondition`

### set_condition

Sets the condition at `index`.

**Parameters:**

- `condition` `DeciderCombinatorCondition` - Data to set selected condition to.
- `index` `uint32` - Index of condition to modify.

### add_condition

Adds a new condition.

**Parameters:**

- `condition` `DeciderCombinatorCondition` - New condition to insert.
- `index` `uint32` *(optional)* - Index to insert new condition at. If not specified, appends to the end.

### remove_condition

Removes the condition at `index`.

**Parameters:**

- `index` `uint32` - Index of condition to remove.

### get_output

Gets the output at `index`.

**Parameters:**

- `index` `uint32` - Index of output to get.

**Returns:**

- `DeciderCombinatorOutput`

### set_output

Sets the output at `index`.

**Parameters:**

- `index` `uint32` - Index of output to modify.
- `output` `DeciderCombinatorOutput` - Data to set selected output to.

### add_output

Adds a new output.

**Parameters:**

- `index` `uint32` *(optional)* - Index to insert new output at. If not specified, appends to the end.
- `output` `DeciderCombinatorOutput` - New output to insert.

### remove_output

Removes the output at `index`.

**Parameters:**

- `index` `uint32` - Index of output to remove.

