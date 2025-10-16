# LuaEquipmentGridPrototype

Prototype of an equipment grid.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### equipment_categories

Equipment category names for the [categories](runtime:LuaEquipmentPrototype::equipment_categories) that may be inserted into this equipment grid. The grid will accept any equipment that has at least one category in this list.

**Read type:** Array[`string`]

### width

**Read type:** `uint32`

### height

**Read type:** `uint32`

### locked

If the player can move equipment into or out of this grid.

**Read type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

