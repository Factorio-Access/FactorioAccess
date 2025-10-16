# on_pre_player_mined_item

Called when the player completes a mining action, but before the entity is potentially removed from the map. This is called even if the entity does not end up being removed.

## Event Data

### entity

**Type:** `LuaEntity`

The entity being mined

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

### tick

**Type:** `uint32`

Tick the event was generated.

