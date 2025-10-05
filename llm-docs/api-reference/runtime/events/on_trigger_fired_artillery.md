# on_trigger_fired_artillery

Called when an entity with a trigger prototype (such as capsules) fire an artillery projectile AND that trigger prototype defined `trigger_fired_artillery=true`.

## Event Data

### entity

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### source

**Type:** `LuaEntity` *(optional)*

### tick

**Type:** `uint32`

Tick the event was generated.

