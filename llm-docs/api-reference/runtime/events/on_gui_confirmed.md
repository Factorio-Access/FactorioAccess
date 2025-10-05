# on_gui_confirmed

Called when a [LuaGuiElement](runtime:LuaGuiElement) is confirmed, for example by pressing Enter in a textfield.

## Event Data

### alt

**Type:** `boolean`

If alt was pressed.

### control

**Type:** `boolean`

If control was pressed.

### element

**Type:** `LuaGuiElement`

The confirmed element.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who did the confirming.

### shift

**Type:** `boolean`

If shift was pressed.

### tick

**Type:** `uint32`

Tick the event was generated.

