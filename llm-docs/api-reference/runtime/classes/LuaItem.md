# LuaItem

A reference to an item with data. In contrast to LuaItemStack, this is binding to a specific item data even if it would move between entities or inventories.

**Parent:** [LuaItemCommon](LuaItemCommon.md)

## Attributes

### type

Type of the item prototype

**Read type:** `string`

### name

Name of the item prototype

**Read type:** `string`

### prototype

Item prototype of this item

**Read type:** `LuaItemPrototype`

### quality

The quality of this item.

**Read type:** `LuaQualityPrototype`

### item_stack

Object representing the item stack this item is located in right now. If its not possible to locate the item stack holding this item, a nil will be returned

**Read type:** `LuaItemStack`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

