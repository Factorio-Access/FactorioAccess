# LuaHeatBufferPrototype

Prototype of a heat buffer.

## Attributes

### max_temperature

**Read type:** `double`

### default_temperature

**Read type:** `double`

### specific_heat

**Read type:** `double`

### max_transfer

**Read type:** `double`

### min_temperature_gradient

**Read type:** `double`

### min_working_temperature

**Read type:** `double`

### minimum_glow_temperature

**Read type:** `double`

### connections

**Read type:** Array[`HeatConnection`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

