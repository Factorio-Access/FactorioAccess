# SmokePrototype

Abstract entity that has an animation.

**Parent:** `EntityPrototype`

## Properties

### Optional Properties

#### affected_by_wind

**Type:** `boolean`

Smoke always moves randomly unless `movement_slow_down_factor` is 0. If `affected_by_wind` is true, the smoke will also be moved by wind.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### animation

**Type:** `Animation`



#### collision_box

**Type:** `BoundingBox`

Must have a collision box size of zero.

**Default:** `Empty = `{{0, 0}, {0, 0}}``

#### color

**Type:** `Color`



**Default:** ``{r=0.375, g=0.375, b=0.375, a=0.375}``

#### cyclic

**Type:** `boolean`

If this is false then the smoke expires when the animation has played once.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### duration

**Type:** `uint32`

May not be 0 if `cyclic` is true. If `cyclic` is false then the smoke will be expire when the animation has played once, even if there would still be duration left.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### end_scale

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### fade_away_duration

**Type:** `uint32`

`fade_in_duration` + `fade_away_duration` must be <= `duration`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### fade_in_duration

**Type:** `uint32`

`fade_in_duration` + `fade_away_duration` must be <= `duration`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### glow_animation

**Type:** `Animation`



#### glow_fade_away_duration

**Type:** `uint32`



**Default:** `The value of `fade_away_duration``

#### movement_slow_down_factor

**Type:** `double`

Value between 0 and 1, with 0 being no movement.

**Default:** `{'complex_type': 'literal', 'value': 0.995}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'smoke'}`

#### show_when_smoke_off

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### spread_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### start_scale

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

