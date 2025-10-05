# on_rocket_launched

Called when a rocket finishes ascending. (Triggers listening for finished rocket launch past 2.0 have been moved to 'on_cargo_pod_finished_ascending' as rocket and cargo pod are two separate entities)

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### rocket

**Type:** `LuaEntity`

### rocket_silo

**Type:** `LuaEntity` *(optional)*

### tick

**Type:** `uint32`

Tick the event was generated.

