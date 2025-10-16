# CharacterPrototype

Entity that you move around on the screen during the campaign and freeplay.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `character`

## Properties

### crafting_speed

**Type:** `double`

**Optional:** Yes

**Default:** 1

### mining_speed

**Type:** `double`

**Required:** Yes

### running_speed

**Type:** `double`

**Required:** Yes

### distance_per_frame

**Type:** `double`

**Required:** Yes

### maximum_corner_sliding_distance

**Type:** `double`

**Required:** Yes

### heartbeat

The sound played when the character's health is low.

**Type:** `Sound`

**Optional:** Yes

### inventory_size

Number of slots in the main inventory. May be 0.

**Type:** `ItemStackIndex`

**Required:** Yes

### guns_inventory_size

Must be between 1 and 15.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 3

### build_distance

**Type:** `uint32`

**Required:** Yes

### drop_item_distance

**Type:** `uint32`

**Required:** Yes

### reach_distance

**Type:** `uint32`

**Required:** Yes

### reach_resource_distance

**Type:** `double`

**Required:** Yes

### item_pickup_distance

**Type:** `double`

**Required:** Yes

### loot_pickup_distance

**Type:** `double`

**Required:** Yes

### ticks_to_keep_gun

**Type:** `uint32`

**Required:** Yes

### ticks_to_keep_aiming_direction

**Type:** `uint32`

**Required:** Yes

### ticks_to_stay_in_combat

**Type:** `uint32`

**Required:** Yes

### damage_hit_tint

**Type:** `Color`

**Required:** Yes

### mining_with_tool_particles_animation_positions

List of positions in the mining with tool animation when the mining sound and mining particles are created.

**Type:** Array[`float`]

**Required:** Yes

**Examples:**

```
mining_with_tool_particles_animation_positions = {28}
```

### running_sound_animation_positions

List of positions in the running animation when the walking sound is played.

**Type:** Array[`float`]

**Required:** Yes

**Examples:**

```
running_sound_animation_positions = {14, 29}
```

### moving_sound_animation_positions

**Type:** Array[`float`]

**Required:** Yes

### animations

**Type:** Array[`CharacterArmorAnimation`]

**Required:** Yes

### crafting_categories

Names of the crafting categories the character can craft recipes from. The built-in categories can be found [here](https://wiki.factorio.com/Data.raw#recipe-category). See also [RecipeCategory](prototype:RecipeCategory).

**Type:** Array[`RecipeCategoryID`]

**Optional:** Yes

### mining_categories

Names of the resource categories the character can mine resources from.

**Type:** Array[`ResourceCategoryID`]

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### flying_bob_speed

**Type:** `float`

**Optional:** Yes

**Default:** 1

### grounded_landing_search_radius

The search radius for a non-colliding position to move the player to if they are grounded mid-flight. Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### enter_vehicle_distance

Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 3.0

### tool_attack_distance

**Type:** `double`

**Optional:** Yes

**Default:** 1.5

### respawn_time

Time in seconds. Must be positive

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### has_belt_immunity

Whether this character is moved by belts when standing on them.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### character_corpse

Name of the character corpse that is spawned when this character dies.

**Type:** `EntityID`

**Optional:** Yes

### flying_collision_mask

This collision mask is used when the character is flying.

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"character/flying"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### tool_attack_result

**Type:** `Trigger`

**Optional:** Yes

### footstep_particle_triggers

Triggered every tick of the running animation.

**Type:** `FootstepTriggerEffectList`

**Optional:** Yes

### synced_footstep_particle_triggers

Triggered when the running animation (`animations`) rolls over the frames defined in `right_footprint_frames` and `left_footprint_frames`.

**Type:** `FootstepTriggerEffectList`

**Optional:** Yes

### footprint_particles

Triggered when the running animation (`animations`) rolls over the frames defined in `right_footprint_frames` and `left_footprint_frames`.

**Type:** Array[`FootprintParticle`]

**Optional:** Yes

### left_footprint_offset

Offset from the center of the entity for the left footprint. Used by `footprint_particles`.

**Type:** `Vector`

**Optional:** Yes

### right_footprint_offset

Offset from the center of the entity for the right footprint. Used by `footprint_particles`.

**Type:** `Vector`

**Optional:** Yes

### right_footprint_frames

The frames in the running animation (`animations`) where the right foot touches the ground.

**Type:** Array[`float`]

**Optional:** Yes

### left_footprint_frames

The frames in the running animation (`animations`) where the left foot touches the ground.

**Type:** Array[`float`]

**Optional:** Yes

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

