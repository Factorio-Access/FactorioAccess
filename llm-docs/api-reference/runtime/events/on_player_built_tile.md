# on_player_built_tile

Called after a player builds tiles.

## Event Data

### inventory

**Type:** `LuaInventory` *(optional)*

The inventory containing the items used to build the tiles.

### item

**Type:** `LuaItemPrototype` *(optional)*

The item type used to build the tiles

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

### quality

**Type:** `LuaQualityPrototype` *(optional)*

The quality of the item used to build the tiles

### surface_index

**Type:** `uint`

The surface the tile(s) were built on.

### tick

**Type:** `uint`

Tick the event was generated.

### tile

**Type:** `LuaTilePrototype`

The tile prototype that was placed.

### tiles

**Type:** Array[`OldTileAndPosition`]

The position data.

