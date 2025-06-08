# CharacterPrototype

Entity that you move around on the screen during the campaign and freeplay.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### animations

**Type:** ``CharacterArmorAnimation`[]`



#### build_distance

**Type:** `uint32`



#### damage_hit_tint

**Type:** `Color`



#### distance_per_frame

**Type:** `double`



#### drop_item_distance

**Type:** `uint32`



#### eat

**Type:** `Sound`

The sound played when the character eats (fish for example).

#### heartbeat

**Type:** `Sound`

The sound played when the character's health is low.

#### inventory_size

**Type:** `ItemStackIndex`

Number of slots in the main inventory. May be 0.

#### item_pickup_distance

**Type:** `double`



#### loot_pickup_distance

**Type:** `double`



#### maximum_corner_sliding_distance

**Type:** `double`



#### mining_speed

**Type:** `double`



#### mining_with_tool_particles_animation_positions

**Type:** ``float`[]`

List of positions in the mining with tool animation when the mining sound and mining particles are created.

#### moving_sound_animation_positions

**Type:** ``float`[]`



#### reach_distance

**Type:** `uint32`



#### reach_resource_distance

**Type:** `double`



#### running_sound_animation_positions

**Type:** ``float`[]`

List of positions in the running animation when the walking sound is played.

#### running_speed

**Type:** `double`



#### ticks_to_keep_aiming_direction

**Type:** `uint32`



#### ticks_to_keep_gun

**Type:** `uint32`



#### ticks_to_stay_in_combat

**Type:** `uint32`



### Optional Properties

#### character_corpse

**Type:** `EntityID`

Name of the character corpse that is spawned when this character dies.

#### crafting_categories

**Type:** ``RecipeCategoryID`[]`

Names of the crafting categories the character can craft recipes from. The built-in categories can be found [here](https://wiki.factorio.com/Data.raw#recipe-category). See also [RecipeCategory](prototype:RecipeCategory).

#### enter_vehicle_distance

**Type:** `double`

Must be >= 0.

**Default:** `{'complex_type': 'literal', 'value': 3.0}`

#### flying_bob_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### flying_collision_mask

**Type:** `CollisionMaskConnector`

This collision mask is used when the character is flying.

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"character/flying"`.

#### footprint_particles

**Type:** ``FootprintParticle`[]`

Triggered when the running animation (`animations`) rolls over the frames defined in `right_footprint_frames` and `left_footprint_frames`.

#### footstep_particle_triggers

**Type:** `FootstepTriggerEffectList`

Triggered every tick of the running animation.

#### grounded_landing_search_radius

**Type:** `double`

The search radius for a non-colliding position to move the player to if they are grounded mid-flight. Must be >= 0.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### guns_inventory_size

**Type:** `ItemStackIndex`

Must be between 1 and 15.

**Default:** `{'complex_type': 'literal', 'value': 3}`

#### has_belt_immunity

**Type:** `boolean`

Whether this character is moved by belts when standing on them.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### left_footprint_frames

**Type:** ``float`[]`

The frames in the running animation (`animations`) where the left foot touches the ground.

#### left_footprint_offset

**Type:** `Vector`

Offset from the center of the entity for the left footprint. Used by `footprint_particles`.

#### light

**Type:** `LightDefinition`



#### mining_categories

**Type:** ``ResourceCategoryID`[]`

Names of the resource categories the character can mine resources from.

#### respawn_time

**Type:** `uint32`

Time in seconds. Must be positive

**Default:** `{'complex_type': 'literal', 'value': 10}`

#### right_footprint_frames

**Type:** ``float`[]`

The frames in the running animation (`animations`) where the right foot touches the ground.

#### right_footprint_offset

**Type:** `Vector`

Offset from the center of the entity for the right footprint. Used by `footprint_particles`.

#### synced_footstep_particle_triggers

**Type:** `FootstepTriggerEffectList`

Triggered when the running animation (`animations`) rolls over the frames defined in `right_footprint_frames` and `left_footprint_frames`.

#### tool_attack_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1.5}`

#### tool_attack_result

**Type:** `Trigger`



