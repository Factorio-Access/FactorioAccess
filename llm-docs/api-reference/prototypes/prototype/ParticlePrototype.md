# ParticlePrototype

An entity with a limited lifetime that can use trigger effects.

**Parent:** [Prototype](Prototype.md)
**Type name:** `optimized-particle`

## Properties

### pictures

Picture variation count and individual frame count must be equal to shadow variation count.

**Type:** `AnimationVariations`

**Optional:** Yes

### life_time

Can't be 1.

**Type:** `uint16`

**Required:** Yes

### shadows

Shadow variation variation count and individual frame count must be equal to picture variation count.

**Type:** `AnimationVariations`

**Optional:** Yes

### draw_shadow_when_on_ground

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### regular_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### ended_in_water_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### ended_on_ground_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### render_layer_when_on_ground

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### regular_trigger_effect_frequency

Can't be 1.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### movement_modifier_when_on_ground

**Type:** `float`

**Optional:** Yes

**Default:** 0.8

### movement_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

### vertical_acceleration

Has to be >= -0.01 and <= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** -0.004

### mining_particle_frame_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### fade_away_duration

Defaults to `life_time` / 5, but at most 60. If this is 0, it is silently changed to 1.

**Type:** `uint16`

**Optional:** Yes

