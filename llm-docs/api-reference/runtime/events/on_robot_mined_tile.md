# on_robot_mined_tile

Called after a robot mines tiles.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### robot

**Type:** `LuaEntity`

The robot.

### surface_index

**Type:** `uint`

The surface the tile(s) were mined on.

### tick

**Type:** `uint`

Tick the event was generated.

### tiles

**Type:** Array[`OldTileAndPosition`]

The position data.

