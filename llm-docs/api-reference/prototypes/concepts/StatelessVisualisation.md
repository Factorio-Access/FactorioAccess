# StatelessVisualisation

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### animation

One of `nested_visualisations`, `animation` and `light` needs to be defined.

**Type:** `AnimationVariations`

**Optional:** Yes

### shadow

Shadow variation count must be equal to animation variation count.

Only loaded if `animation` is defined.

**Type:** `AnimationVariations`

**Optional:** Yes

### light

One of `nested_visualisations`, `animation` and `light` needs to be defined.

**Type:** `LightDefinition`

**Optional:** Yes

### count

**Type:** `uint16`

**Optional:** Yes

### min_count

Only loaded if `count` is not defined.

**Type:** `uint16`

**Optional:** Yes

**Default:** 1

### max_count

Only loaded if `count` is not defined.

**Type:** `uint16`

**Optional:** Yes

**Default:** "Value of `min_count`"

### period

**Type:** `uint16`

**Optional:** Yes

### particle_tick_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0

### probability

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### offset_x

**Type:** `RangedValue`

**Optional:** Yes

### offset_y

**Type:** `RangedValue`

**Optional:** Yes

### offset_z

**Type:** `RangedValue`

**Optional:** Yes

### speed_x

**Type:** `RangedValue`

**Optional:** Yes

### speed_y

**Type:** `RangedValue`

**Optional:** Yes

### speed_z

**Type:** `RangedValue`

**Optional:** Yes

### acceleration_x

**Type:** `float`

**Optional:** Yes

### acceleration_y

**Type:** `float`

**Optional:** Yes

### acceleration_z

**Type:** `float`

**Optional:** Yes

### movement_slowdown_factor_x

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

### movement_slowdown_factor_y

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

### movement_slowdown_factor_z

Silently clamped to be between 0 and 1.

**Type:** `float`

**Optional:** Yes

### scale

**Type:** `RangedValue`

**Optional:** Yes

### begin_scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### end_scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### fade_in_progress_duration

**Type:** `float`

**Optional:** Yes

**Default:** 0

### fade_out_progress_duration

**Type:** `float`

**Optional:** Yes

**Default:** 0

### spread_progress_duration

**Type:** `float`

**Optional:** Yes

**Default:** 1

### adjust_animation_speed_by_base_scale

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### affected_by_wind

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### positions

Array may be at most 32 elements.

**Type:** Array[`Vector`]

**Optional:** Yes

### nested_visualisations

One of `nested_visualisations`, `animation` and `light` needs to be defined.

**Type:** `StatelessVisualisation` | Array[`StatelessVisualisation`]

**Optional:** Yes

### can_lay_on_the_ground

**Type:** `boolean`

**Optional:** Yes

**Default:** True

