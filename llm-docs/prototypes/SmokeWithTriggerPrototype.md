# SmokeWithTriggerPrototype

An entity with animation and a trigger.

**Parent:** `SmokePrototype`

## Properties

### Optional Properties

#### action

**Type:** `Trigger`



#### action_cooldown

**Type:** `uint32`

0 means never apply.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### attach_to_target

**Type:** `boolean`

If true, causes the smoke to move with the target entity if one is specified.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### fade_when_attachment_is_destroyed

**Type:** `boolean`

If true, the smoke will immediately start fading away when the entity it is attached to is destroyed. If it was never attached to an entity in the first place, then the smoke will fade away immediately after being created.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### particle_count

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_distance_scale_factor

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### particle_duration_variation

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### particle_scale_factor

**Type:** `Vector`



#### particle_spread

**Type:** `Vector`



#### spread_duration_variation

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### wave_distance

**Type:** `Vector`



#### wave_speed

**Type:** `Vector`



