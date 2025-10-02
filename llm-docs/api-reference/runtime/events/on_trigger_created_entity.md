# on_trigger_created_entity

Called when an entity with a trigger prototype (such as capsules) create an entity AND that trigger prototype defined `trigger_created_entity=true`.

## Event Data

### entity

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### source

**Type:** `LuaEntity` *(optional)*

### tick

**Type:** `uint`

Tick the event was generated.

