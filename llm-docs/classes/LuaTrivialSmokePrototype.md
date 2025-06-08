# LuaTrivialSmokePrototype

Prototype of a trivial smoke.

**Parent:** `LuaPrototypeBase`

## Attributes

### affected_by_wind

**Type:** `boolean` _(read-only)_



### color

**Type:** `Color` _(read-only)_



### cyclic

**Type:** `boolean` _(read-only)_



### duration

**Type:** `uint` _(read-only)_



### end_scale

**Type:** `double` _(read-only)_



### fade_away_duration

**Type:** `uint` _(read-only)_



### fade_in_duration

**Type:** `uint` _(read-only)_



### glow_animation

**Type:** `boolean` _(read-only)_



### glow_fade_away_duration

**Type:** `uint` _(read-only)_



### movement_slow_down_factor

**Type:** `double` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### render_layer

**Type:** `RenderLayer` _(read-only)_



### show_when_smoke_off

**Type:** `boolean` _(read-only)_



### spread_duration

**Type:** `uint` _(read-only)_



### start_scale

**Type:** `double` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

