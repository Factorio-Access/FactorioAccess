# SmokePrototype

Abstract entity that has an animation.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Abstract:** Yes

## Properties

### animation

**Type:** `Animation`

**Optional:** Yes

### cyclic

If this is false then the smoke expires when the animation has played once.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### duration

May not be 0 if `cyclic` is true. If `cyclic` is false then the smoke will be expire when the animation has played once, even if there would still be duration left.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

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

### start_scale

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### end_scale

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### color

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=0.375, g=0.375, b=0.375, a=0.375}`"

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

### movement_slow_down_factor

Value between 0 and 1, with 0 being no movement.

**Type:** `double`

**Optional:** Yes

**Default:** 0.995

### glow_fade_away_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** "The value of `fade_away_duration`"

### glow_animation

**Type:** `Animation`

**Optional:** Yes

### collision_box

Must have a collision box size of zero.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Overrides parent:** Yes

**Examples:**

```
collision_box = {{0, 0}, {0, 0}}
```

