# on_player_mined_tile

Called after a player mines tiles.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

### surface_index

**Type:** `uint32`

The surface the tile(s) were mined from.

### tick

**Type:** `uint32`

Tick the event was generated.

### tiles

**Type:** Array[`OldTileAndPosition`]

The position data.

