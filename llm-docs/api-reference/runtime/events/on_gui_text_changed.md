# on_gui_text_changed

Called when [LuaGuiElement](runtime:LuaGuiElement) text is changed by the player.

## Event Data

### element

**Type:** `LuaGuiElement`

The edited element.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who did the edit.

### text

**Type:** `string`

The new text in the element.

### tick

**Type:** `uint32`

Tick the event was generated.

