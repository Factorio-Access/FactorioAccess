# ExplosionPrototype

Used to play an animation and a sound.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### animations

**Type:** `AnimationVariations`



### Optional Properties

#### beam

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### correct_rotation

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### delay

**Type:** `MapTick`

Number of ticks to delay the explosion effects by.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### delay_deviation

**Type:** `MapTick`

The maximum number of ticks to randomly delay the explosion effects by. In addition to the number of ticks defined by `delay`, the explosion will be delayed by a random number of ticks between 0 and `delay_deviation` (inclusive).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### explosion_effect

**Type:** `Trigger`

The effect/trigger that happens when the explosion effect triggers after the initial delay as defined by `delay` and `delay_deviation`.

#### fade_in_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### fade_out_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### height

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### light

**Type:** `LightDefinition`



#### light_intensity_factor_final

**Type:** `float`

Silently clamped to be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### light_intensity_factor_initial

**Type:** `float`

Silently clamped to be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### light_intensity_peak_end_progress

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.9}`

#### light_intensity_peak_start_progress

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### light_size_factor_final

**Type:** `float`

Silently clamped to be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### light_size_factor_initial

**Type:** `float`

Silently clamped to be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.05}`

#### light_size_peak_end_progress

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.5}`

#### light_size_peak_start_progress

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'explosion'}`

#### rotate

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### scale

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### scale_animation_speed

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### scale_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### scale_end

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### scale_in_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### scale_increment_per_tick

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### scale_initial

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### scale_initial_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### scale_out_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### smoke

**Type:** `TrivialSmokeID`

Mandatory if `smoke_count` > 0.

#### smoke_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### smoke_slow_down_factor

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### sound

**Type:** `Sound`



