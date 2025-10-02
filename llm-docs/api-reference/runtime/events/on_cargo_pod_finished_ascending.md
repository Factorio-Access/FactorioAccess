# on_cargo_pod_finished_ascending

Called when a cargo pod departs a surface.

## Event Data

### cargo_pod

**Type:** `LuaEntity`

### launched_by_rocket

**Type:** `boolean`

True for pods spawned on a rocket. This event triggers for platform and modded pods as well, but only when true will the pod count towards rocket launch statistics and trigger 'rocket-launched' achievement with objective_condition.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player that is riding the cargo pod, if any.

### tick

**Type:** `uint`

Tick the event was generated.

