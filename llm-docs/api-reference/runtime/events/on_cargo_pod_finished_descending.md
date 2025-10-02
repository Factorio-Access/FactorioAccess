# on_cargo_pod_finished_descending

Called when a cargo pods lands on a surface, either at a station or on the ground.

## Event Data

### cargo_pod

**Type:** `LuaEntity`

### launched_by_rocket

**Type:** `boolean`

True for pods spawned on a rocket.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player that is riding the cargo pod, if any.

### tick

**Type:** `uint`

Tick the event was generated.

