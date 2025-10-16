# LuaModData

Arbitrary data provided by mods.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### data_type

**Read type:** `string`

### data

Provides full data of this prototype.

**Read type:** Dictionary[`string`, `AnyBasic`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get

Provides partial access to the data.

**Parameters:**

- `key` `string`

**Returns:**

- `AnyBasic` *(optional)*

