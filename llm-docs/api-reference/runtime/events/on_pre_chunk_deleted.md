# on_pre_chunk_deleted

Called before one or more chunks are deleted using [LuaSurface::delete_chunk](runtime:LuaSurface::delete_chunk).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### positions

**Type:** Array[`ChunkPosition`]

The chunks to be deleted.

### surface_index

**Type:** `uint32`

### tick

**Type:** `uint32`

Tick the event was generated.

