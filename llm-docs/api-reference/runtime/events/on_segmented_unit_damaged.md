# on_segmented_unit_damaged

Called when a segmented unit is damaged. This is not called when a segmented unit's health is set directly by another mod.

## Event Data

### cause

**Type:** `LuaEntity` *(optional)*

The entity that originally triggered the events that led to this damage, if available (e.g. the character, turret, etc. that pulled the trigger).

### damage_type

**Type:** `LuaDamagePrototype`

### final_damage_amount

**Type:** `float`

The damage amount after resistances.

### final_health

**Type:** `float`

The health of the unit after the damage was applied.

### force

**Type:** `LuaForce` *(optional)*

The force that did the attacking.

### name

**Type:** `defines.events`

Identifier of the event

### original_damage_amount

**Type:** `float`

The damage amount before resistances.

### segmented_unit

**Type:** `LuaSegmentedUnit`

### source

**Type:** `LuaEntity` *(optional)*

The entity that is directly dealing the damage, if available (e.g. the projectile, flame, sticker, grenade, laser beam, etc.).

### tick

**Type:** `uint`

Tick the event was generated.

