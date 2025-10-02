# on_sector_scanned

Called when an entity of type `radar` finishes scanning a sector.

## Event Data

### area

**Type:** `BoundingBox`

Area of the scanned chunk.

### chunk_position

**Type:** `ChunkPosition`

The chunk scanned.

### name

**Type:** `defines.events`

Identifier of the event

### radar

**Type:** `LuaEntity`

The radar that did the scanning.

### tick

**Type:** `uint`

Tick the event was generated.

