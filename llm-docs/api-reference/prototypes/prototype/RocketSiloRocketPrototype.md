# RocketSiloRocketPrototype

The rocket inside the rocket silo.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `rocket-silo-rocket`

## Properties

### shadow_slave_entity

**Type:** `EntityID`

**Optional:** Yes

### cargo_pod_entity

Name of a [CargoPodPrototype](prototype:CargoPodPrototype).

**Type:** `EntityID`

**Required:** Yes

### dying_explosion

**Type:** `EntityID`

**Optional:** Yes

### glow_light

**Type:** `LightDefinition`

**Optional:** Yes

### rocket_sprite

**Type:** `Sprite`

**Optional:** Yes

### rocket_shadow_sprite

**Type:** `Sprite`

**Optional:** Yes

### rocket_glare_overlay_sprite

**Type:** `Sprite`

**Optional:** Yes

### rocket_smoke_bottom1_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_smoke_bottom2_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_smoke_top1_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_smoke_top2_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_smoke_top3_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_flame_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_flame_left_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_flame_right_animation

**Type:** `Animation`

**Optional:** Yes

### rocket_initial_offset

**Type:** `Vector`

**Optional:** Yes

### rocket_rise_offset

**Type:** `Vector`

**Required:** Yes

### cargo_attachment_offset

**Type:** `Vector`

**Optional:** Yes

### rocket_flame_left_rotation

**Type:** `float`

**Required:** Yes

### rocket_flame_right_rotation

**Type:** `float`

**Required:** Yes

### rocket_render_layer_switch_distance

**Type:** `double`

**Required:** Yes

### full_render_layer_switch_distance

**Type:** `double`

**Required:** Yes

### rocket_launch_offset

**Type:** `Vector`

**Required:** Yes

### effects_fade_in_start_distance

**Type:** `double`

**Required:** Yes

### effects_fade_in_end_distance

**Type:** `double`

**Required:** Yes

### shadow_fade_out_start_ratio

**Type:** `double`

**Required:** Yes

### shadow_fade_out_end_ratio

**Type:** `double`

**Required:** Yes

### rocket_visible_distance_from_center

**Type:** `float`

**Required:** Yes

### rocket_above_wires_slice_offset_from_center

**Type:** `float`

**Optional:** Yes

**Default:** -3

### rocket_air_object_slice_offset_from_center

**Type:** `float`

**Optional:** Yes

**Default:** -6

### rocket_fog_mask

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

**Default:** "`{rect={{-30, -30}, {30, rocket_above_wires_slice_offset_from_center}}, falloff=1}`"

### rising_speed

**Type:** `double`

**Required:** Yes

### engine_starting_speed

**Type:** `double`

**Required:** Yes

### flying_speed

**Type:** `double`

**Required:** Yes

### flying_acceleration

**Type:** `double`

**Required:** Yes

### flying_trigger

**Type:** `TriggerEffect`

**Optional:** Yes

### flying_sound

**Type:** `Sound`

**Optional:** Yes

### inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

