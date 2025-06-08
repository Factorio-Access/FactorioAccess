# SpiderLegPrototype

Used by [SpiderLegSpecification](prototype:SpiderLegSpecification) for [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype), also known as [spidertron](https://wiki.factorio.com/Spidertron).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### base_position_selection_distance

**Type:** `double`



#### initial_movement_speed

**Type:** `double`



#### knee_distance_factor

**Type:** `double`

The placement of the knee relative to the torso of the spider and the end of the foot when at rest. Used to calculate the shape of the leg and the length of the individual parts. Values between 0 and 1 place the knee between the torso and the leg. Values closer to 0 will place the knee closer to the torso.

#### knee_height

**Type:** `double`

The resting height of the knee from the ground. Used to derive leg part length and size. If set too low, this could cause the knee to invert, bending inwards underneath the spider.

#### minimal_step_size

**Type:** `double`



#### movement_acceleration

**Type:** `double`



#### movement_based_position_selection_distance

**Type:** `double`



#### target_position_randomisation_distance

**Type:** `double`



### Optional Properties

#### ankle_height

**Type:** `double`

The height of the foot from the ground when at rest.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### graphics_set

**Type:** `SpiderLegGraphicsSet`



#### hip_flexibility

**Type:** `double`

The flexibility of hip. Must be between 0 and 1 inclusive. 0 means the hip doesn't flex at all, and 1 means the hip can bend the entire range, from straight up to straight down. Values less than one will dampen the hip flexibility and cause the upper and lower leg parts to stretch and squish more to compensate. Does not affect movement, only graphics.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### lower_leg_dying_trigger_effects

**Type:** ``SpiderLegTriggerEffect`[]`



#### stretch_force_scalar

**Type:** `double`

A scalar that controls the amount of influence this leg has over the position of the torso. Must be greater than 0.

**Default:** `{'complex_type': 'literal', 'value': 0.715}`

#### upper_leg_dying_trigger_effects

**Type:** ``SpiderLegTriggerEffect`[]`



#### walking_sound_speed_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### walking_sound_volume_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

