# on_player_alt_selected_area

Called after a player alt-selects an area with a selection-tool item.

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

**Type:** `uint`

The player doing the selection.

### quality

**Type:** `string`

The item quality used to select the area.

### surface

**Type:** `LuaSurface`

The surface selected.

### tick

**Type:** `uint`

Tick the event was generated.

### tiles

**Type:** Array[`LuaTile`]

The tiles selected.

