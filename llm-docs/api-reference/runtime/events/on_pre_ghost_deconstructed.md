# on_pre_ghost_deconstructed

Called before a ghost entity is destroyed as a result of being marked for deconstruction.

Also called for item request proxies before they are destroyed as a result of being marked for deconstruction.

## Event Data

### ghost

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player that did the deconstruction if any.

### tick

**Type:** `uint32`

Tick the event was generated.

