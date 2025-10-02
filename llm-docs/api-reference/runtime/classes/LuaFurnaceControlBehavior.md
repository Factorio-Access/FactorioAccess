# LuaFurnaceControlBehavior

Control behavior for furnaces.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### circuit_read_contents

`true` if the furnace reads its ingredients contents, product contents and materials in crafting.

**Read type:** `boolean`

**Write type:** `boolean`

### include_in_crafting

`true` if the read contents should include items in crafting.

**Read type:** `boolean`

**Write type:** `boolean`

### include_fuel

`true` if the read contents should include fuel (content of energy source)

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_read_ingredients

`true` if the furnace outputs ingredients of current recipe as a signals to circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_read_recipe_finished

`true` if the the furnace sends a signal when the recipe finishes.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_recipe_finished_signal

The signal sent when the furnace finishes a recipe.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### circuit_read_working

`true` if the the furnace sends a signal when it is working.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_working_signal

The signal sent when the furnace is working.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

