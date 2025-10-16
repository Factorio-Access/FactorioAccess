# on_gui_opened

Called when the player opens a GUI.

## Event Data

### element

**Type:** `LuaGuiElement` *(optional)*

The custom GUI element that was opened.

### entity

**Type:** `LuaEntity` *(optional)*

The entity or entity grid whose GUI was opened.

### equipment

**Type:** `LuaEquipment` *(optional)*

The equipment whose GUI was opened.

### gui_type

**Type:** `defines.gui_type`

The type of GUI that was opened.

### inventory

**Type:** `LuaInventory` *(optional)*

The script inventory whose GUI was opened.

### item

**Type:** `LuaItemStack` *(optional)*

The item whose GUI was opened.

### name

**Type:** `defines.events`

Identifier of the event

### other_player

**Type:** `LuaPlayer` *(optional)*

The other player whose GUI was opened.

### player_index

**Type:** `uint32`

The player closing the GUI.

### surface_index

**Type:** `uint32` *(optional)*

The surface index of the global electric network whose GUI was opened.

### tick

**Type:** `uint32`

Tick the event was generated.

### tile_position

**Type:** `TilePosition` *(optional)*

The position of the tile whose GUI was opened.

