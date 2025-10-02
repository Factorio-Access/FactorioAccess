# LuaEquipment

An item in a [LuaEquipmentGrid](runtime:LuaEquipmentGrid), for example a fusion reactor placed in one's power armor.

An equipment reference becomes invalid once the equipment is removed or the equipment grid it resides in is destroyed.

## Attributes

### name

Name of this equipment.

**Read type:** `string`

### ghost_name

Name of the equipment contained in this ghost

**Read type:** `string`

**Subclasses:** Ghost

### type

Type of this equipment.

**Read type:** `string`

### ghost_type

Type of the equipment contained in this ghost.

**Read type:** `string`

**Subclasses:** Ghost

### quality

Quality of this equipment.

**Read type:** `LuaQualityPrototype`

### position

Position of this equipment in the equipment grid.

**Read type:** `EquipmentPosition`

### shape

Shape of this equipment.

**Read type:** Table (see below for parameters)

### shield

Current shield value of the equipment. Can't be set higher than [LuaEquipment::max_shield](runtime:LuaEquipment::max_shield).

Trying to write this value on non-shield equipment will throw an error.

**Read type:** `double`

**Write type:** `double`

### max_shield

Maximum shield value. `0` if this equipment doesn't have a shield.

**Read type:** `double`

### max_solar_power

Maximum energy per tick crated by this equipment on the current surface. Actual generated energy varies depending on the daylight levels.

**Read type:** `double`

### inventory_bonus

Inventory size bonus.

**Read type:** `uint`

### movement_bonus

Movement speed bonus.

**Read type:** `double`

### generator_power

Energy generated per tick.

**Read type:** `double`

### energy

Current available energy.

**Read type:** `double`

**Write type:** `double`

### max_energy

Maximum amount of energy that can be stored in this equipment.

**Read type:** `double`

### prototype

**Read type:** `LuaEquipmentPrototype`

### ghost_prototype

The prototype of the equipment contained in this ghost.

**Read type:** `LuaEquipmentPrototype`

**Subclasses:** Ghost

### burner

The burner energy source for this equipment, if any.

**Read type:** `LuaBurner`

**Optional:** Yes

### to_be_removed

If this equipment is marked to be removed.

**Read type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

