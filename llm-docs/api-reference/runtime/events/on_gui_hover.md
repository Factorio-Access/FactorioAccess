# on_gui_hover

Called when [LuaGuiElement](runtime:LuaGuiElement) is hovered by the mouse.

Only fired for events whose [LuaGuiElement::raise_hover_events](runtime:LuaGuiElement::raise_hover_events) is `true`.

## Event Data

### element

**Type:** `LuaGuiElement`

The element that is being hovered over.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player whose cursor is hovering.

### tick

**Type:** `uint32`

Tick the event was generated.

