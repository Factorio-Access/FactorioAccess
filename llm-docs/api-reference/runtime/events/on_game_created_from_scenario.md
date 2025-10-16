# on_game_created_from_scenario

Called when a game is created from a scenario. This is fired for every mod, even when the scenario's save data already includes it. In those cases however, [LuaBootstrap::on_init](runtime:LuaBootstrap::on_init) is not fired.

This event is not fired when the scenario is loaded via the map editor.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint32`

Tick the event was generated.

