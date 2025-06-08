# LuaFurnaceControlBehavior

Control behavior for furnaces.

**Parent:** `LuaGenericOnOffControlBehavior`

## Attributes

### circuit_read_contents

**Type:** `boolean`

`true` if the furnace reads its ingredients contents, product contents and materials in crafting.

### circuit_read_ingredients

**Type:** `boolean`

`true` if the furnace outputs ingredients of current recipe as a signals to circuit network.

### circuit_read_recipe_finished

**Type:** `boolean`

`true` if the the furnace sends a signal when the recipe finishes.

### circuit_read_working

**Type:** `boolean`

`true` if the the furnace sends a signal when it is working.

### circuit_recipe_finished_signal

**Type:** `SignalID`

The signal sent when the furnace finishes a recipe.

### circuit_working_signal

**Type:** `SignalID`

The signal sent when the furnace is working.

### include_fuel

**Type:** `boolean`

`true` if the read contents should include fuel (content of energy source)

### include_in_crafting

**Type:** `boolean`

`true` if the read contents should include items in crafting.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

