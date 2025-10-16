# on_space_platform_built_tile

Called after a space platform builds tiles.

## Event Data

### inventory

**Type:** `LuaInventory`

The inventory containing the stacks used to build the tiles.

### item

**Type:** `LuaItemPrototype`

The item type used to build the tiles.

### name

**Type:** `defines.events`

Identifier of the event

### platform

**Type:** `LuaSpacePlatform`

The platform.

### quality

**Type:** `LuaQualityPrototype`

The quality the item used to build the tiles.

### surface_index

**Type:** `uint32`

The surface the tile(s) are build on.

### tick

**Type:** `uint32`

Tick the event was generated.

### tile

**Type:** `LuaTilePrototype`

The tile prototype that was placed.

### tiles

**Type:** Array[`OldTileAndPosition`]

The position data.

