# on_chart_tag_modified

Called when a chart tag is modified by a player or by script.

## Event Data

### force

**Type:** `LuaForce`

### name

**Type:** `defines.events`

Identifier of the event

### old_icon

**Type:** `SignalID`

### old_player_index

**Type:** `uint32` *(optional)*

### old_position

**Type:** `MapPosition`

### old_surface

**Type:** `LuaSurface`

### old_text

**Type:** `string`

### player_index

**Type:** `uint32` *(optional)*

### tag

**Type:** `LuaCustomChartTag`

### tick

**Type:** `uint32`

Tick the event was generated.

