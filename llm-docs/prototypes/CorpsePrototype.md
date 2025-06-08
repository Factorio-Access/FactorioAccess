# CorpsePrototype

Used for corpses, for example the remnants when destroying buildings.

**Parent:** `EntityPrototype`

## Properties

### Optional Properties

#### animation

**Type:** `RotatedAnimationVariations`

The dying animation.

#### animation_overlay

**Type:** `RotatedAnimationVariations`

Variation count must be the same as `animation` variation count. Direction count must be the same as `animation` direction count. Frame count must be the same as `animation` frame count.

#### animation_overlay_final_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'corpse'}`

#### animation_overlay_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### animation_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### auto_setup_collision_box

**Type:** `boolean`

If true, and the collision box is unset, this will take the collision box of the first entity that uses this corpse.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### decay_animation

**Type:** `RotatedAnimationVariations`



#### decay_frame_transition_duration

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### direction_shuffle

**Type:** ```uint16`[]`[]`

An array of arrays of integers. The inner arrays are called "groups" and must all have the same size.

#### dying_speed

**Type:** `float`

Multiplier for `time_before_shading_off` and `time_before_removed`. Must be positive.

Controls the speed of the animation: `1 ÷ dying_speed = duration of the animation`

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### expires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### final_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'corpse'}`

#### ground_patch

**Type:** `AnimationVariations`



#### ground_patch_decay

**Type:** `AnimationVariations`



#### ground_patch_fade_in_delay

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### ground_patch_fade_in_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### ground_patch_fade_out_duration

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### ground_patch_fade_out_start

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### ground_patch_higher

**Type:** `AnimationVariations`



#### ground_patch_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'ground-patch'}`

#### remove_on_entity_placement

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### remove_on_tile_placement

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### shuffle_directions_at_frame

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### splash

**Type:** `AnimationVariations`



#### splash_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### splash_speed

**Type:** `float`

Controls the speed of the splash animation: `1 ÷ splash_speed = duration of the splash animation`

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### time_before_removed

**Type:** `uint32`

Time in ticks this corpse lasts. May not be 0.

**Default:** `60 * 120 (120 seconds)`

#### time_before_shading_off

**Type:** `uint32`

Controls how long the corpse takes to fade, as in how long it takes to get from no transparency to full transparency/removed. This time is *not* added to `time_before_removed`, it is instead subtracted from it. So by default, the corpse starts fading about 15 seconds before it gets removed.

**Default:** `60 * 15 (15 seconds)`

#### underwater_layer_offset

**Type:** `int8`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### underwater_patch

**Type:** `RotatedSprite`



#### use_decay_layer

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### use_tile_color_for_ground_patch_tint

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

