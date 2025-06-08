# RocketSiloRocketPrototype

The rocket inside the rocket silo.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### cargo_pod_entity

**Type:** `EntityID`

Name of a [CargoPodPrototype](prototype:CargoPodPrototype).

#### effects_fade_in_end_distance

**Type:** `double`



#### effects_fade_in_start_distance

**Type:** `double`



#### engine_starting_speed

**Type:** `double`



#### flying_acceleration

**Type:** `double`



#### flying_speed

**Type:** `double`



#### full_render_layer_switch_distance

**Type:** `double`



#### inventory_size

**Type:** `ItemStackIndex`



#### rising_speed

**Type:** `double`



#### rocket_flame_left_rotation

**Type:** `float`



#### rocket_flame_right_rotation

**Type:** `float`



#### rocket_launch_offset

**Type:** `Vector`



#### rocket_render_layer_switch_distance

**Type:** `double`



#### rocket_rise_offset

**Type:** `Vector`



#### rocket_visible_distance_from_center

**Type:** `float`



#### shadow_fade_out_end_ratio

**Type:** `double`



#### shadow_fade_out_start_ratio

**Type:** `double`



### Optional Properties

#### cargo_attachment_offset

**Type:** `Vector`



#### dying_explosion

**Type:** `EntityID`



#### flying_sound

**Type:** `Sound`



#### flying_trigger

**Type:** `TriggerEffect`



#### glow_light

**Type:** `LightDefinition`



#### rocket_above_wires_slice_offset_from_center

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': -3}`

#### rocket_air_object_slice_offset_from_center

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': -6}`

#### rocket_flame_animation

**Type:** `Animation`



#### rocket_flame_left_animation

**Type:** `Animation`



#### rocket_flame_right_animation

**Type:** `Animation`



#### rocket_fog_mask

**Type:** `FogMaskShapeDefinition`



**Default:** ``{rect={{-30, -30}, {30, rocket_above_wires_slice_offset_from_center}}, falloff=1}``

#### rocket_glare_overlay_sprite

**Type:** `Sprite`



#### rocket_initial_offset

**Type:** `Vector`



#### rocket_shadow_sprite

**Type:** `Sprite`



#### rocket_smoke_bottom1_animation

**Type:** `Animation`



#### rocket_smoke_bottom2_animation

**Type:** `Animation`



#### rocket_smoke_top1_animation

**Type:** `Animation`



#### rocket_smoke_top2_animation

**Type:** `Animation`



#### rocket_smoke_top3_animation

**Type:** `Animation`



#### rocket_sprite

**Type:** `Sprite`



#### shadow_slave_entity

**Type:** `EntityID`



