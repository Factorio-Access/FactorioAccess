# on_biter_base_built

Called when a biter migration builds a base.

This will be called multiple times for each migration, once for every biter that is sacrificed to build part of the new base.

## Event Data

### entity

**Type:** `LuaEntity`

The entity that was built.

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint32`

Tick the event was generated.

