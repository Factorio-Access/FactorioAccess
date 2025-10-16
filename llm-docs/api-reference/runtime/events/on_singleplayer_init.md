# on_singleplayer_init

Called when [LuaGameScript::is_multiplayer](runtime:LuaGameScript::is_multiplayer) changes to false. May also be raised when it was already false but a game was loaded from a save file without hosting.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint32`

Tick the event was generated.

