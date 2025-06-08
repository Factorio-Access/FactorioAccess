# TrivialSmokePrototype

Smoke, but it's not an entity for optimization purposes.

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### animation

**Type:** `Animation`



#### duration

**Type:** `uint32`

Can't be 0 - the smoke will never render.

### Optional Properties

#### affected_by_wind

**Type:** `boolean`

Smoke always moves randomly unless `movement_slow_down_factor` is 0. If `affected_by_wind` is true, the smoke will also be moved by wind.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### color

**Type:** `Color`



**Default:** ``{r=0.375, g=0.375, b=0.375, a=0.375}``

#### cyclic

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### end_scale

**Type:** `float`



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



**Default:** `Value of `fade_away_duration``

#### movement_slow_down_factor

**Type:** `double`

Value between 0 and 1, with 1 being no slowdown and 0 being no movement.

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

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

