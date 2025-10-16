# FireFlamePrototype

A fire.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `fire`

## Properties

### damage_per_tick

**Type:** `DamageParameters`

**Required:** Yes

### spread_delay

**Type:** `uint32`

**Required:** Yes

### spread_delay_deviation

**Type:** `uint32`

**Required:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### initial_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### secondary_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### small_tree_fire_pictures

**Type:** `AnimationVariations`

**Optional:** Yes

### pictures

**Type:** `AnimationVariations`

**Optional:** Yes

### smoke_source_pictures

**Type:** `AnimationVariations`

**Optional:** Yes

### secondary_pictures

**Type:** `AnimationVariations`

**Optional:** Yes

### burnt_patch_pictures

**Type:** `SpriteVariations`

**Optional:** Yes

### secondary_picture_fade_out_start

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### secondary_picture_fade_out_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### spawn_entity

**Type:** `EntityID`

**Optional:** Yes

### smoke

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### maximum_spread_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 200

### initial_flame_count

Spawns this many `secondary_pictures` around the entity when it first spawns. It waits `delay_between_initial_flames` between each spawned `secondary_pictures`. This can be used to make fires look less repetitive.

For example, spitters use this to make several smaller splashes around the main one.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### uses_alternative_behavior

If `false`, then all animations loop. If `true`, they run once and stay on the final frame. Also changes the behavior of several other fire properties as mentioned in their descriptions.

For example, spitters use alternate behavior, flamethrower flames don't.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### limit_overlapping_particles

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tree_dying_factor

**Type:** `float`

**Optional:** Yes

**Default:** 0

### fade_in_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### fade_out_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### initial_lifetime

**Type:** `uint32`

**Optional:** Yes

**Default:** 300

### damage_multiplier_decrease_per_tick

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### damage_multiplier_increase_per_added_fuel

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### maximum_damage_multiplier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### lifetime_increase_by

**Type:** `uint32`

**Optional:** Yes

**Default:** 20

### lifetime_increase_cooldown

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### maximum_lifetime

**Type:** `uint32`

**Optional:** Yes

**Default:** "Max uint32"

### add_fuel_cooldown

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### delay_between_initial_flames

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### smoke_fade_in_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### smoke_fade_out_duration

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### on_fuel_added_action

**Type:** `Trigger`

**Optional:** Yes

### on_damage_tick_effect

**Type:** `Trigger`

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### light_size_modifier_per_flame

**Type:** `float`

**Optional:** Yes

**Default:** 0

### light_size_modifier_maximum

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_alpha_blend_duration

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### burnt_patch_lifetime

**Type:** `uint32`

**Optional:** Yes

**Default:** 1800

### burnt_patch_alpha_default

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_alpha

Only loaded if `uses_alternative_behavior` is true.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_alpha_deviation

Only loaded if `uses_alternative_behavior` is true.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### flame_alpha

Only loaded if `uses_alternative_behavior` is false.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### flame_alpha_deviation

Only loaded if `uses_alternative_behavior` is false.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### burnt_patch_alpha_variations

**Type:** Array[`TileAndAlpha`]

**Optional:** Yes

