# SmokeWithTriggerPrototype

An entity with animation and a trigger.

**Parent:** [SmokePrototype](SmokePrototype.md)
**Type name:** `smoke-with-trigger`

## Properties

### action

**Type:** `Trigger`

**Optional:** Yes

### action_cooldown

0 means never apply.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### particle_count

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### particle_distance_scale_factor

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### spread_duration_variation

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### particle_duration_variation

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### particle_spread

**Type:** `Vector`

**Optional:** Yes

### particle_scale_factor

**Type:** `Vector`

**Optional:** Yes

### wave_distance

**Type:** `Vector`

**Optional:** Yes

### wave_speed

**Type:** `Vector`

**Optional:** Yes

### attach_to_target

If true, causes the smoke to move with the target entity if one is specified.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### fade_when_attachment_is_destroyed

If true, the smoke will immediately start fading away when the entity it is attached to is destroyed. If it was never attached to an entity in the first place, then the smoke will fade away immediately after being created.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

