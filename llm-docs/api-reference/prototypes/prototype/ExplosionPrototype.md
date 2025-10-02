# ExplosionPrototype

Used to play an animation and a sound.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `explosion`

## Properties

### animations

**Type:** `AnimationVariations`

**Required:** Yes

### sound

**Type:** `Sound`

**Optional:** Yes

### smoke

Mandatory if `smoke_count` > 0.

**Type:** `TrivialSmokeID`

**Optional:** Yes

### height

**Type:** `float`

**Optional:** Yes

**Default:** 1

### smoke_slow_down_factor

**Type:** `float`

**Optional:** Yes

**Default:** 0

### smoke_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### rotate

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### beam

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### correct_rotation

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scale_animation_speed

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### fade_in_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### fade_out_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "explosion"

### scale_in_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### scale_out_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### scale_end

**Type:** `float`

**Optional:** Yes

**Default:** 1

### scale_increment_per_tick

**Type:** `float`

**Optional:** Yes

**Default:** 0

### light_intensity_factor_initial

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### light_intensity_factor_final

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### light_size_factor_initial

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.05

### light_size_factor_final

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### light

**Type:** `LightDefinition`

**Optional:** Yes

### light_intensity_peak_start_progress

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### light_intensity_peak_end_progress

**Type:** `float`

**Optional:** Yes

**Default:** 0.9

### light_size_peak_start_progress

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### light_size_peak_end_progress

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### scale_initial

**Type:** `float`

**Optional:** Yes

**Default:** 1

### scale_initial_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### scale_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### delay

Number of ticks to delay the explosion effects by.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### delay_deviation

The maximum number of ticks to randomly delay the explosion effects by. In addition to the number of ticks defined by `delay`, the explosion will be delayed by a random number of ticks between 0 and `delay_deviation` (inclusive).

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### explosion_effect

The effect/trigger that happens when the explosion effect triggers after the initial delay as defined by `delay` and `delay_deviation`.

**Type:** `Trigger`

**Optional:** Yes

