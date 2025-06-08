# FireFlamePrototype

A fire.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### damage_per_tick

**Type:** `DamageParameters`



#### spread_delay

**Type:** `uint32`



#### spread_delay_deviation

**Type:** `uint32`



### Optional Properties

#### add_fuel_cooldown

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 10}`

#### burnt_patch_alpha_default

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### burnt_patch_alpha_variations

**Type:** ``TileAndAlpha`[]`



#### burnt_patch_lifetime

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 1800}`

#### burnt_patch_pictures

**Type:** `SpriteVariations`



#### damage_multiplier_decrease_per_tick

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### damage_multiplier_increase_per_added_fuel

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### delay_between_initial_flames

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 10}`

#### fade_in_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### fade_out_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### flame_alpha

**Type:** `float`

Only loaded if `uses_alternative_behavior` is false.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### flame_alpha_deviation

**Type:** `float`

Only loaded if `uses_alternative_behavior` is false.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### initial_flame_count

**Type:** `uint8`

Spawns this many `secondary_pictures` around the entity when it first spawns. It waits `delay_between_initial_flames` between each spawned `secondary_pictures`. This can be used to make fires look less repetitive.

For example, spitters use this to make several smaller splashes around the main one.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### initial_lifetime

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 300}`

#### initial_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### lifetime_increase_by

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 20}`

#### lifetime_increase_cooldown

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 10}`

#### light

**Type:** `LightDefinition`



#### light_size_modifier_maximum

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### light_size_modifier_per_flame

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### limit_overlapping_particles

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### maximum_damage_multiplier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### maximum_lifetime

**Type:** `uint32`



**Default:** `Max uint32`

#### maximum_spread_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 200}`

#### on_damage_tick_effect

**Type:** `Trigger`



#### on_fuel_added_action

**Type:** `Trigger`



#### particle_alpha

**Type:** `float`

Only loaded if `uses_alternative_behavior` is true.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_alpha_blend_duration

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### particle_alpha_deviation

**Type:** `float`

Only loaded if `uses_alternative_behavior` is true.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### pictures

**Type:** `AnimationVariations`



#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### secondary_picture_fade_out_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### secondary_picture_fade_out_start

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### secondary_pictures

**Type:** `AnimationVariations`



#### secondary_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### small_tree_fire_pictures

**Type:** `AnimationVariations`



#### smoke

**Type:** ``SmokeSource`[]`



#### smoke_fade_in_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### smoke_fade_out_duration

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### smoke_source_pictures

**Type:** `AnimationVariations`



#### spawn_entity

**Type:** `EntityID`



#### tree_dying_factor

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### uses_alternative_behavior

**Type:** `boolean`

If `false`, then all animations loop. If `true`, they run once and stay on the final frame. Also changes the behavior of several other fire properties as mentioned in their descriptions.

For example, spitters use alternate behavior, flamethrower flames don't.

**Default:** `{'complex_type': 'literal', 'value': False}`

