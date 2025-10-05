# LuaSimulation

Functions for use during simulations. This object cannot be saved, and cannot be used outside of a simulation.

The simulation object instance can be obtained from [LuaGameScript::simulation](runtime:LuaGameScript::simulation).

## Attributes

### camera_player_cursor_position

**Read type:** `MapPosition`

**Write type:** `MapPosition`

**Optional:** Yes

### camera_position

**Read type:** `MapPosition`

**Write type:** `MapPosition`

**Optional:** Yes

### camera_surface_index

**Read type:** `uint32`

**Write type:** `uint32`

**Optional:** Yes

### hide_cursor

**Write type:** `boolean`

### camera_zoom

**Write type:** `double`

### camera_player

**Write type:** `PlayerIdentification`

### camera_player_cursor_direction

**Write type:** `defines.direction`

### camera_alt_info

**Write type:** `boolean`

### smart_belt_building

**Write type:** `boolean`

**Optional:** Yes

### gui_tooltip_interval

**Write type:** `double`

### active_quickbars

**Write type:** `uint8`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### create_test_player

**Parameters:**

- `name` `string` - The name of the new player.

**Returns:**

- `LuaPlayer` - The created player.

### get_slot_position

**Parameters:**

- `inventory` `"character"` | `"entity"` *(optional)* - Defaults to `"character"`.
- `inventory_index` `InventoryIndex`
- `slot_index` `ItemStackIndex` - This index is 0-based, unlike other inventory indices.

**Returns:**

- `MapPosition` *(optional)* - Position of the GUI slot on the screen, if successfully found.

### get_widget_position

**Parameters:**

- `data` `string` *(optional)*
- `data2` `string` *(optional)*
- `type` `SimulationWidgetType`

**Returns:**

- `MapPosition` *(optional)* - Center of the GUI widget on the screen, if successfully found.

### activate_rail_planner

Activate the rail planner at the given position.

**Parameters:**

- `build_mode` `defines.build_mode` *(optional)* - Defaults to [normal](runtime:defines.build_mode.normal).
- `ghost_mode` `boolean` *(optional)* - Defaults to `false`.
- `position` `MapPosition` *(optional)*

### deactivate_rail_planner

Deactivate the rail planner.

### move_cursor

Move the cursor towards the given position at the given speed.

**Parameters:**

- `position` `MapPosition`
- `speed` `double` *(optional)* - Defaults to `0.2`.

**Returns:**

- `boolean` - Whether the cursor will reach the target position with this move.

### mouse_down

Send a left mouse button-down event at its current position.

### mouse_up

Send a left mouse button-up event at its current position.

### mouse_click

Send a left mouse button click event at its current position. This is equivalent to calling [LuaSimulation::mouse_down](runtime:LuaSimulation::mouse_down), then [LuaSimulation::mouse_up](runtime:LuaSimulation::mouse_up).

### control_down

Send a control press event at the current cursor position.

**Parameters:**

- `control` `string` - The name of the control input to press.
- `notify` `boolean` - Whether to show flying text of the activated control.

### control_up

Send a control release event at the current cursor position.

**Parameters:**

- `control` `string` - The name of the control input to release.

### control_press

Send a control down and up event at the current cursor position. This is equivalent to calling [LuaSimulation::control_down](runtime:LuaSimulation::control_down), then [LuaSimulation::control_up](runtime:LuaSimulation::control_up).

**Parameters:**

- `control` `string` - The name of the control input to press and release.
- `notify` `boolean` - Whether to show flying text of the activated control.

### write

Write text as if it was typed by a player. Overwrites existing text by selecting it first.

**Parameters:**

- `text` `string` *(optional)* - The text to write. Does nothing if no text is provided.

### scroll_clipboard_forwards

Scroll the clipboard forwards by one entry.

### scroll_clipboard_backwards

Scroll the clipboard backwards by one entry.

