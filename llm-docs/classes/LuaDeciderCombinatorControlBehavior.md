# LuaDeciderCombinatorControlBehavior

Control behavior for decider combinators.

**Parent:** `LuaCombinatorControlBehavior`

## Methods

### add_condition

Adds a new condition.

**Parameters:**

- `condition` `DeciderCombinatorCondition`: New condition to insert.
- `index` `uint` _(optional)_: Index to insert new condition at. If not specified, appends to the end.

### add_output

Adds a new output.

**Parameters:**

- `index` `uint` _(optional)_: Index to insert new output at. If not specified, appends to the end.
- `output` `DeciderCombinatorOutput`: New output to insert.

### get_condition

Gets the condition at `index`.

**Parameters:**

- `index` `uint`: Index of condition to get.

**Returns:**

- `DeciderCombinatorCondition`: 

### get_output

Gets the output at `index`.

**Parameters:**

- `index` `uint`: Index of output to get.

**Returns:**

- `DeciderCombinatorOutput`: 

### remove_condition

Removes the condition at `index`.

**Parameters:**

- `index` `uint`: Index of condition to remove.

### remove_output

Removes the output at `index`.

**Parameters:**

- `index` `uint`: Index of output to remove.

### set_condition

Sets the condition at `index`.

**Parameters:**

- `condition` `DeciderCombinatorCondition`: Data to set selected condition to.
- `index` `uint`: Index of condition to modify.

### set_output

Sets the output at `index`.

**Parameters:**

- `index` `uint`: Index of output to modify.
- `output` `DeciderCombinatorOutput`: Data to set selected output to.

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### parameters

**Type:** `DeciderCombinatorParameters`

This decider combinator's parameters. Writing `nil` clears the combinator's parameters.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

