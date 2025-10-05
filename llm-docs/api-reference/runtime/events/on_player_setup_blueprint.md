# on_player_setup_blueprint

Called when a player selects an area with a blueprint.

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

### mapping

**Type:** LuaLazyLoadedValue[Dictionary[`uint32`, `LuaEntity`]]

The blueprint entity index to source entity mapping. Note: if any mod changes the blueprint this will be incorrect.

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

The record that is being reassigned.

### stack

**Type:** `LuaItemStack` *(optional)*

The item stack used to select the area.

### surface

**Type:** `LuaSurface`

The surface selected.

### tick

**Type:** `uint32`

Tick the event was generated.

