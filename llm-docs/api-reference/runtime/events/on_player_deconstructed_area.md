# on_player_deconstructed_area

Called when a player selects an area with a deconstruction planner.

## Event Data

### alt

**Type:** `boolean`

If normal selection or alt selection was used.

### area

**Type:** `BoundingBox`

The area selected.

### item

**Type:** `string`

The item used to select the area.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player doing the selection.

### quality

**Type:** `string`

The item quality used to select the area.

### record

**Type:** `LuaRecord` *(optional)*

The record that was used to select the area.

### stack

**Type:** `LuaItemStack` *(optional)*

The item stack used to select the area.

### surface

**Type:** `LuaSurface`

The surface selected.

### tick

**Type:** `uint32`

Tick the event was generated.

