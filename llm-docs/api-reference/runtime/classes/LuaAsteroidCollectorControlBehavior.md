# LuaAsteroidCollectorControlBehavior

Control behavior for asteroid collectors.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### set_filter

`true` if this asteroid collector has filters set from circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### read_content

`true` if this asteroid collector reads its content and sends it to a circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### include_hands

`true` if read contents should include content of hands (items that were captured but are not yet in the asteroid collector's main inventory).

**Read type:** `boolean`

**Write type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

