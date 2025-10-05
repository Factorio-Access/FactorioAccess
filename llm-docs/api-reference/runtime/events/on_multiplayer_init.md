# on_multiplayer_init

Called when [LuaGameScript::is_multiplayer](runtime:LuaGameScript::is_multiplayer) changes to true. May also be raised when it was already true but a game was loaded from a save file and with hosting.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint32`

Tick the event was generated.

