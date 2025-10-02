# LuaLoaderControlBehavior

Control behavior for loaders.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### circuit_set_filters

`true` if filters are set from circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_read_transfers

`true` if the transfers between loader's belt and container should be pulsed to the circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

