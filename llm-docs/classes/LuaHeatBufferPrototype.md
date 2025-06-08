# LuaHeatBufferPrototype

Prototype of a heat buffer.

## Attributes

### connections

**Type:** ``HeatConnection`[]` _(read-only)_



### default_temperature

**Type:** `double` _(read-only)_



### max_temperature

**Type:** `double` _(read-only)_



### max_transfer

**Type:** `double` _(read-only)_



### min_temperature_gradient

**Type:** `double` _(read-only)_



### min_working_temperature

**Type:** `double` _(read-only)_



### minimum_glow_temperature

**Type:** `double` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### specific_heat

**Type:** `double` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

