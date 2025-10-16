# LuaTrivialSmokePrototype

Prototype of a trivial smoke.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### color

**Read type:** `Color`

### start_scale

**Read type:** `double`

### end_scale

**Read type:** `double`

### movement_slow_down_factor

**Read type:** `double`

### duration

**Read type:** `uint32`

### spread_duration

**Read type:** `uint32`

### fade_away_duration

**Read type:** `uint32`

### fade_in_duration

**Read type:** `uint32`

### glow_fade_away_duration

**Read type:** `uint32`

### cyclic

**Read type:** `boolean`

### affected_by_wind

**Read type:** `boolean`

### show_when_smoke_off

**Read type:** `boolean`

### glow_animation

**Read type:** `boolean`

### render_layer

**Read type:** `RenderLayer`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

