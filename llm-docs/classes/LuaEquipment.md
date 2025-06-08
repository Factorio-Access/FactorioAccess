# LuaEquipment

An item in a [LuaEquipmentGrid](runtime:LuaEquipmentGrid), for example a fusion reactor placed in one's power armor.

An equipment reference becomes invalid once the equipment is removed or the equipment grid it resides in is destroyed.

## Attributes

### burner

**Type:** `LuaBurner` _(read-only)_

The burner energy source for this equipment, if any.

### energy

**Type:** `double`

Current available energy.

### generator_power

**Type:** `double` _(read-only)_

Energy generated per tick.

### ghost_name

**Type:** `string` _(read-only)_

Name of the equipment contained in this ghost

### ghost_prototype

**Type:** `LuaEquipmentPrototype` _(read-only)_

The prototype of the equipment contained in this ghost.

### ghost_type

**Type:** `string` _(read-only)_

Type of the equipment contained in this ghost.

### inventory_bonus

**Type:** `uint` _(read-only)_

Inventory size bonus.

### max_energy

**Type:** `double` _(read-only)_

Maximum amount of energy that can be stored in this equipment.

### max_shield

**Type:** `double` _(read-only)_

Maximum shield value. `0` if this equipment doesn't have a shield.

### max_solar_power

**Type:** `double` _(read-only)_

Maximum energy per tick crated by this equipment on the current surface. Actual generated energy varies depending on the daylight levels.

### movement_bonus

**Type:** `double` _(read-only)_

Movement speed bonus.

### name

**Type:** `string` _(read-only)_

Name of this equipment.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### position

**Type:** `EquipmentPosition` _(read-only)_

Position of this equipment in the equipment grid.

### prototype

**Type:** `LuaEquipmentPrototype` _(read-only)_



### quality

**Type:** `LuaQualityPrototype` _(read-only)_

Quality of this equipment.

### shape

**Type:** `unknown` _(read-only)_

Shape of this equipment.

### shield

**Type:** `double`

Current shield value of the equipment. Can't be set higher than [LuaEquipment::max_shield](runtime:LuaEquipment::max_shield).

Trying to write this value on non-shield equipment will throw an error.

### to_be_removed

**Type:** `boolean` _(read-only)_

If this equipment is marked to be removed.

### type

**Type:** `string` _(read-only)_

Type of this equipment.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

