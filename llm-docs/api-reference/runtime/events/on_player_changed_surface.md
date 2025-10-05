# on_player_changed_surface

Called after a player changes surfaces.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who changed surfaces.

### surface_index

**Type:** `uint32` *(optional)*

The surface index the player was on - may be `nil` if the surface no longer exists.

### tick

**Type:** `uint32`

Tick the event was generated.

