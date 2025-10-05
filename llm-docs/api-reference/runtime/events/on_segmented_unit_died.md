# on_segmented_unit_died

Called when a segmented unit dies.

## Event Data

### cause

**Type:** `LuaEntity` *(optional)*

The entity that did the killing if available.

### damage_type

**Type:** `LuaDamagePrototype` *(optional)*

The damage type if any.

### force

**Type:** `LuaForce` *(optional)*

The force that did the killing if any.

### name

**Type:** `defines.events`

Identifier of the event

### segmented_unit

**Type:** `LuaSegmentedUnit`

The unit that died.

### tick

**Type:** `uint32`

Tick the event was generated.

