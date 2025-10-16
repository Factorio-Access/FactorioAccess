# on_marked_for_upgrade

Called when an entity is marked for upgrade with the upgrade planner or via script.

## Event Data

### entity

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

### previous_quality

**Type:** `LuaQualityPrototype` *(optional)*

Previous upgrade target quality, if entity was already marked for upgrade.

### previous_target

**Type:** `LuaEntityPrototype` *(optional)*

Previous upgrade target of the entity, if entity was already marked for upgrade.

### quality

**Type:** `LuaQualityPrototype`

The target quality.

### target

**Type:** `LuaEntityPrototype`

### tick

**Type:** `uint32`

Tick the event was generated.

