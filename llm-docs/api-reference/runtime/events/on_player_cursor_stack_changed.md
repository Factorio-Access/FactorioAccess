# on_player_cursor_stack_changed

Called after a player's [cursor stack](runtime:LuaControl::cursor_stack) changed in some way.

This is fired in the same tick that the change happens, but not instantly.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

### tick

**Type:** `uint`

Tick the event was generated.

