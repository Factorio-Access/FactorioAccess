# LuaAsteroidChunkPrototype

Prototype of an asteroid chunk.

**Parent:** `LuaPrototypeBase`

## Attributes

### factoriopedia_alternative

**Type:** `LuaAsteroidChunkPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### hide_from_signal_gui

**Type:** `boolean` _(read-only)_



### item_signal_alias

**Type:** `LuaItemPrototype` _(read-only)_



### mineable_properties

**Type:** `MineableProperties` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

