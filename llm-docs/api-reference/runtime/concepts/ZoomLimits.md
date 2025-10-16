# ZoomLimits

A set of limitations for the player zoom level.

**Type:** Table

## Parameters

### closest

The closest zoom level that the player's current controller can have. If not defined when overwriting [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), then the default value for the current controller as defined by the engine will be used instead. When reading from [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), this field will contain the value previously set by a script or the default value defined by the engine.

**Type:** `ZoomSpecification`

**Optional:** Yes

### furthest

The furthest zoom level that the player's current controller can have. If for any reason the `furthest` limit is closer than `closest`, then the player's zoom will be locked to the closer of the two values. If not defined when overwriting [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), then the default value for the current controller as defined by the engine will be used instead. When reading from [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), this field will contain the value previously set by a script or the default value defined by the engine.

**Type:** `ZoomSpecification`

**Optional:** Yes

### furthest_game_view

The furthest zoom level at which the engine will render the game view. Zoom levels further than this limit will render using chart (map) view. Set this to the same value as `furthest` to force the game view at all zoom levels. Set this to some value closer than `closest` to force chart view at all zoom levels. If not defined when overwriting [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), then the default value for the current controller as defined by the engine will be used instead. When reading from [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits), this field will contain the value previously set by a script or the default value defined by the engine.

**Type:** `ZoomSpecification`

**Optional:** Yes

## Examples

```
```
{
  closest = { zoom = 4 },
  furthest = { zoom = 1 / 16 },
  furthest_game_view = { distance = 200, max_distance = 400 }
}
```
```

