# ChunkPosition

Coordinates of a chunk in a [LuaSurface](runtime:LuaSurface) where each integer `x`/`y` represents a different chunk. This uses the same format as [MapPosition](runtime:MapPosition), meaning it can be specified either with or without explicit keys. A [MapPosition](runtime:MapPosition) can be translated to a ChunkPosition by dividing the `x`/`y` values by 32.

**Type:** Table (see below for parameters) | (`int32`, `int32`)

