# LuaBurner

A reference to the burner energy source owned by a specific [LuaEntity](runtime:LuaEntity) or [LuaEquipment](runtime:LuaEquipment).

## Attributes

### owner

The owner of this burner energy source

**Read type:** `LuaEntity` | `LuaEquipment`

### inventory

The fuel inventory.

**Read type:** `LuaInventory`

### burnt_result_inventory

The burnt result inventory.

**Read type:** `LuaInventory`

### heat

The current heat (energy) stored in this burner.

**Read type:** `double`

**Write type:** `double`

### heat_capacity

The maximum heat (maximum energy) that this burner can store.

**Read type:** `double`

### remaining_burning_fuel

The amount of energy left in the currently-burning fuel item.

Writing to this will silently do nothing if there's no [LuaBurner::currently_burning](runtime:LuaBurner::currently_burning) set.

**Read type:** `double`

**Write type:** `double`

### currently_burning

The currently burning item. Writing `nil` will void the currently burning item without producing a [LuaBurner::burnt_result](runtime:LuaBurner::burnt_result).

Writing to this automatically handles correcting [LuaBurner::remaining_burning_fuel](runtime:LuaBurner::remaining_burning_fuel).

**Read type:** `ItemIDAndQualityIDPair`

**Write type:** `ItemWithQualityID`

**Optional:** Yes

### fuel_categories

The fuel categories this burner uses.

The value in the dictionary is meaningless and exists just to allow for easy lookup.

**Read type:** Dictionary[`string`, `True`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

