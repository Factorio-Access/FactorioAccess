# ParticlePrototype

An entity with a limited lifetime that can use trigger effects.

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### life_time

**Type:** `uint16`

Can't be 1.

### Optional Properties

#### draw_shadow_when_on_ground

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### ended_in_water_trigger_effect

**Type:** `TriggerEffect`



#### ended_on_ground_trigger_effect

**Type:** `TriggerEffect`



#### fade_away_duration

**Type:** `uint16`

Defaults to `life_time` / 5, but at most 60. If this is 0, it is silently changed to 1.

#### mining_particle_frame_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### movement_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### movement_modifier_when_on_ground

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.8}`

#### pictures

**Type:** `AnimationVariations`

Picture variation count and individual frame count must be equal to shadow variation count.

#### regular_trigger_effect

**Type:** `TriggerEffect`



#### regular_trigger_effect_frequency

**Type:** `uint32`

Can't be 1.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### render_layer_when_on_ground

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### shadows

**Type:** `AnimationVariations`

Shadow variation variation count and individual frame count must be equal to picture variation count.

#### vertical_acceleration

**Type:** `float`

Has to be >= -0.01 and <= 0.01.

**Default:** `{'complex_type': 'literal', 'value': -0.004}`

