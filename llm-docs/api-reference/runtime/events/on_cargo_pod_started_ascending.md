# on_cargo_pod_started_ascending

Called when a cargo pod departs from a space platform hub or by another method not attached to a rocket.

## Event Data

### cargo_pod

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player that is riding the cargo pod, if any.

### tick

**Type:** `uint32`

Tick the event was generated.

