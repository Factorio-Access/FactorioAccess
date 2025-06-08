# ArtilleryFlarePrototype

The entity spawned by the [artillery targeting remote](https://wiki.factorio.com/Artillery_targeting_remote).

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### life_time

**Type:** `uint16`



#### map_color

**Type:** `Color`



### Optional Properties

#### creation_shift

**Type:** `Vector`



#### early_death_ticks

**Type:** `uint32`

How long this flare stays alive after `shots_per_flare` amount of shots have been shot at it.

**Default:** `{'complex_type': 'literal', 'value': 180}`

#### ended_in_water_trigger_effect

**Type:** `TriggerEffect`



#### initial_frame_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### initial_height

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### initial_speed

**Type:** `Vector`



#### initial_vertical_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### movement_modifier

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### movement_modifier_when_on_ground

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.8}`

#### pictures

**Type:** `AnimationVariations`

Picture variation count and individual frame count must be equal to shadow variation count.

#### regular_trigger_effect

**Type:** `TriggerEffect`



#### regular_trigger_effect_frequency

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### render_layer_when_on_ground

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### selection_priority

**Type:** `uint8`

The entity with the higher number is selectable before the entity with the lower number.

**Default:** `{'complex_type': 'literal', 'value': 48}`

#### shadows

**Type:** `AnimationVariations`

Shadow variation variation count and individual frame count must be equal to picture variation count.

#### shot_category

**Type:** `AmmoCategoryID`



#### shots_per_flare

**Type:** `uint32`

How many artillery shots should be fired at the position of this flare.

**Default:** `{'complex_type': 'literal', 'value': 1}`

