# on_gui_leave

Called when the player's cursor leaves a [LuaGuiElement](runtime:LuaGuiElement) that was previously hovered.

Only fired for events whose [LuaGuiElement::raise_hover_events](runtime:LuaGuiElement::raise_hover_events) is `true`.

## Event Data

### element

**Type:** `LuaGuiElement`

The element that was being hovered.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player whose cursor was hovering.

### tick

**Type:** `uint32`

Tick the event was generated.

