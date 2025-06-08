# LuaSimulation

Functions for use during simulations. This object cannot be saved, and cannot be used outside of a simulation.

The simulation object instance can be obtained from [LuaGameScript::simulation](runtime:LuaGameScript::simulation).

## Methods

### activate_rail_planner

Activate the rail planner at the given position.

**Parameters:**

- `build_mode` `defines.build_mode` _(optional)_: Defaults to [normal](runtime:defines.build_mode.normal).
- `ghost_mode` `boolean` _(optional)_: Defaults to `false`.
- `position` `MapPosition` _(optional)_: 

### control_down

Send a control press event at the current cursor position.

**Parameters:**

- `control` `string`: The name of the control input to press.
- `notify` `boolean`: Whether to show flying text of the activated control.

### control_press

Send a control down and up event at the current cursor position. This is equivalent to calling [LuaSimulation::control_down](runtime:LuaSimulation::control_down), then [LuaSimulation::control_up](runtime:LuaSimulation::control_up).

**Parameters:**

- `control` `string`: The name of the control input to press and release.
- `notify` `boolean`: Whether to show flying text of the activated control.

### control_up

Send a control release event at the current cursor position.

**Parameters:**

- `control` `string`: The name of the control input to release.

### create_test_player



**Parameters:**

- `name` `string`: The name of the new player.

**Returns:**

- `LuaPlayer`: The created player.

### deactivate_rail_planner

Deactivate the rail planner.

### get_slot_position



**Parameters:**

- `inventory`  _(optional)_: Defaults to `"character"`.
- `inventory_index` `InventoryIndex`: 
- `slot_index` `ItemStackIndex`: This index is 0-based, unlike other inventory indices.

**Returns:**

- `MapPosition`: Position of the GUI slot on the screen, if successfully found.

### get_widget_position



**Parameters:**

- `data` `string` _(optional)_: 
- `data2` `string` _(optional)_: 
- `type` `SimulationWidgetType`: 

**Returns:**

- `MapPosition`: Center of the GUI widget on the screen, if successfully found.

### mouse_click

Send a left mouse button click event at its current position. This is equivalent to calling [LuaSimulation::mouse_down](runtime:LuaSimulation::mouse_down), then [LuaSimulation::mouse_up](runtime:LuaSimulation::mouse_up).

### mouse_down

Send a left mouse button-down event at its current position.

### mouse_up

Send a left mouse button-up event at its current position.

### move_cursor

Move the cursor towards the given position at the given speed.

**Parameters:**

- `position` `MapPosition`: 
- `speed` `double` _(optional)_: Defaults to `0.2`.

**Returns:**

- `boolean`: Whether the cursor will reach the target position with this move.

### scroll_clipboard_backwards

Scroll the clipboard backwards by one entry.

### scroll_clipboard_forwards

Scroll the clipboard forwards by one entry.

### write

Write text as if it was typed by a player. Overwrites existing text by selecting it first.

**Parameters:**

- `text` `string` _(optional)_: The text to write. Does nothing if no text is provided.

## Attributes

### active_quickbars

**Type:** `any`



### camera_alt_info

**Type:** `any`



### camera_player

**Type:** `any`



### camera_player_cursor_direction

**Type:** `any`



### camera_player_cursor_position

**Type:** `MapPosition`



### camera_position

**Type:** `MapPosition`



### camera_surface_index

**Type:** `uint`



### camera_zoom

**Type:** `any`



### gui_tooltip_interval

**Type:** `any`



### hide_cursor

**Type:** `any`



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### smart_belt_building

**Type:** `any`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

