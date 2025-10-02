# on_chunk_deleted

Called when one or more chunks are deleted using [LuaSurface::delete_chunk](runtime:LuaSurface::delete_chunk).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### positions

**Type:** Array[`ChunkPosition`]

The chunks deleted.

### surface_index

**Type:** `uint`

### tick

**Type:** `uint`

Tick the event was generated.

