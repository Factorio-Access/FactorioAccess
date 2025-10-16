# TrivialSmokePrototype

Smoke, but it's not an entity for optimization purposes.

**Parent:** [Prototype](Prototype.md)
**Type name:** `trivial-smoke`
**Instance limit:** 255

## Properties

### animation

**Type:** `Animation`

**Required:** Yes

### duration

Can't be 0 - the smoke will never render.

**Type:** `uint32`

**Required:** Yes

### glow_animation

**Type:** `Animation`

**Optional:** Yes

### color

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=0.375, g=0.375, b=0.375, a=0.375}`"

### start_scale

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### end_scale

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### movement_slow_down_factor

Value between 0 and 1, with 1 being no slowdown and 0 being no movement.

**Type:** `double`

**Optional:** Yes

**Default:** 0.995

### spread_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### fade_away_duration

`fade_in_duration` + `fade_away_duration` must be <= `duration`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### fade_in_duration

`fade_in_duration` + `fade_away_duration` must be <= `duration`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### glow_fade_away_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `fade_away_duration`"

### cyclic

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### affected_by_wind

Smoke always moves randomly unless `movement_slow_down_factor` is 0. If `affected_by_wind` is true, the smoke will also be moved by wind.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### show_when_smoke_off

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "smoke"

