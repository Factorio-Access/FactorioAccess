# on_space_platform_mined_tile

Called after a platform mines tiles.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### platform

**Type:** `LuaSpacePlatform`

The platform.

### surface_index

**Type:** `uint`

The surface the tile(s) were mined on.

### tick

**Type:** `uint`

Tick the event was generated.

### tiles

**Type:** Array[`OldTileAndPosition`]

The position data.

