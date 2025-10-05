# on_gui_closed

Called when the player closes the GUI they have open.

This can only be raised when the GUI's player controller is still valid. If a GUI is thus closed due to the player disconnecting, dying, or becoming a spectator in other ways, it won't cause this event to be raised.

It's not advised to open any other GUI during this event because if this is run as a request to open a different GUI the game will force close the new opened GUI without notice to ensure the original requested GUI is opened.

## Event Data

### element

**Type:** `LuaGuiElement` *(optional)*

The custom GUI element that was closed.

### entity

**Type:** `LuaEntity` *(optional)*

The entity or entity grid whose GUI was closed.

### equipment

**Type:** `LuaEquipment` *(optional)*

The equipment whose GUI was closed.

### gui_type

**Type:** `defines.gui_type`

The type of GUI that was closed.

### inventory

**Type:** `LuaInventory` *(optional)*

The script inventory whose GUI was closed.

### item

**Type:** `LuaItemStack` *(optional)*

The item whose GUI was closed.

### name

**Type:** `defines.events`

Identifier of the event

### other_player

**Type:** `LuaPlayer` *(optional)*

The other player whose GUI was closed.

### player_index

**Type:** `uint32`

The player closing the GUI.

### surface_index

**Type:** `uint32` *(optional)*

The surface index of the global electric network whose GUI was closed.

### tick

**Type:** `uint32`

Tick the event was generated.

### tile_position

**Type:** `TilePosition` *(optional)*

The position of the tile whose GUI was closed.

