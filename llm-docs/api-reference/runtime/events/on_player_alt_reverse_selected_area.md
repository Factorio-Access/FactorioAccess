# on_player_alt_reverse_selected_area

Called after a player alt-reverse-selects an area with a selection-tool item.

## Event Data

### area

**Type:** `BoundingBox`

The area selected.

### entities

**Type:** Array[`LuaEntity`]

The entities selected.

### item

**Type:** `string`

The item used to select the area.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player doing the selection.

### surface

**Type:** `LuaSurface`

The surface selected.

### tick

**Type:** `uint32`

Tick the event was generated.

### tiles

**Type:** Array[`LuaTile`]

The tiles selected.

