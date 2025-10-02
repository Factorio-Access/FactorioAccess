# LuaAISettings

Collection of settings for overriding default ai behavior.

## Attributes

### allow_destroy_when_commands_fail

If enabled, units that repeatedly fail to succeed at commands will be destroyed.

**Read type:** `boolean`

**Write type:** `boolean`

### allow_try_return_to_spawner

If enabled, units that have nothing else to do will attempt to return to a spawner.

**Read type:** `boolean`

**Write type:** `boolean`

### do_separation

If enabled, units will try to separate themselves from nearby friendly units.

**Read type:** `boolean`

**Write type:** `boolean`

### path_resolution_modifier

Defines how coarse the pathfinder's grid is, where smaller values mean a coarser grid. Defaults to `0`, which equals a resolution of `1x1` tiles, centered on tile centers. Values range from `-8` to `8` inclusive, where each integer increment doubles/halves the resolution. So, a resolution of `-8` equals a grid of `256x256` tiles, and a resolution of `8` equals `1/256` of a tile.

**Read type:** `int8`

**Write type:** `int8`

### size_in_group

The number of "slots" that the unit takes up in a unit group. Must be greater than 0.

If this value is changed after the unit has been added to a group, the exact behavior is undefined.

**Read type:** `float`

**Write type:** `float`

### join_attacks

If enabled, the unit will join attack groups.

**Read type:** `boolean`

**Write type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

