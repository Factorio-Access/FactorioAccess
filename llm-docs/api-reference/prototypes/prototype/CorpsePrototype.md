# CorpsePrototype

Used for corpses, for example the remnants when destroying buildings.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `corpse`

## Properties

### dying_speed

Multiplier for `time_before_shading_off` and `time_before_removed`. Must be positive.

Controls the speed of the animation: `1 ÷ dying_speed = duration of the animation`

**Type:** `float`

**Optional:** Yes

**Default:** 1

### splash_speed

Controls the speed of the splash animation: `1 ÷ splash_speed = duration of the splash animation`

**Type:** `float`

**Optional:** Yes

**Default:** 1

### time_before_shading_off

Controls how long the corpse takes to fade, as in how long it takes to get from no transparency to full transparency/removed. This time is *not* added to `time_before_removed`, it is instead subtracted from it. So by default, the corpse starts fading about 15 seconds before it gets removed.

**Type:** `uint32`

**Optional:** Yes

**Default:** "60 * 15 (15 seconds)"

### time_before_removed

Time in ticks this corpse lasts. May not be 0.

**Type:** `uint32`

**Optional:** Yes

**Default:** "60 * 120 (120 seconds)"

### expires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### protected_from_tile_building

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

### remove_on_entity_placement

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### remove_on_tile_placement

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### auto_setup_collision_box

If true, and the collision box is unset, this will take the collision box of the first entity that uses this corpse.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### final_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "corpse"

### ground_patch_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "ground-patch"

### animation_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### splash_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### animation_overlay_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### animation_overlay_final_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "corpse"

### shuffle_directions_at_frame

Defines after which frame in the `animation` the `direction_shuffle` should be applied. Can be set to `0`, frames are 1-indexed.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### use_tile_color_for_ground_patch_tint

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### use_decay_layer

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### underwater_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 1

### ground_patch_fade_in_delay

**Type:** `float`

**Optional:** Yes

**Default:** 0

### ground_patch_fade_in_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### ground_patch_fade_out_start

**Type:** `float`

**Optional:** Yes

**Default:** 0

### decay_frame_transition_duration

**Type:** `float`

**Optional:** Yes

**Default:** 0

### animation

The dying animation.

**Type:** `RotatedAnimationVariations`

**Optional:** Yes

### animation_overlay

Variation count must be the same as `animation` variation count. Direction count must be the same as `animation` direction count. Frame count must be the same as `animation` frame count.

**Type:** `RotatedAnimationVariations`

**Optional:** Yes

### decay_animation

**Type:** `RotatedAnimationVariations`

**Optional:** Yes

### splash

**Type:** `AnimationVariations`

**Optional:** Yes

### ground_patch

**Type:** `AnimationVariations`

**Optional:** Yes

### ground_patch_higher

**Type:** `AnimationVariations`

**Optional:** Yes

### ground_patch_decay

**Type:** `AnimationVariations`

**Optional:** Yes

### underwater_patch

**Type:** `RotatedSprite`

**Optional:** Yes

### ground_patch_fade_out_duration

**Type:** `float`

**Optional:** Yes

**Default:** 0

### direction_shuffle

May not be an empty array. May not be used if there is no `animation` defined.

The inner arrays are called "groups" and must all have the same size.

The indices map to the directions of `animation` and they are 1-indexed. After the `shuffle_directions_at_frame` frame of the `animation`, these indices are used as the direction when choosing which frame to render. The chosen shuffled direction can be any direction in the same group as the non-shuffled direction. Which direction is chosen from the group depends on the shuffle variation which is `dying_graphics_variation % group_size`.

**Type:** Array[Array[`uint16`]]

**Optional:** Yes

**Default:** "No direction shuffle"

