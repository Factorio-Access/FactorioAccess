# CranePart

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### orientation_shift

Angle in radian, which is internally converted to a [RealOrientation](prototype:RealOrientation).

**Type:** `float`

**Optional:** Yes

**Default:** 0

### is_contractible_by_cropping

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### should_scale_for_perspective

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### scale_to_fit_model

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_sprite_rotation

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### snap_start

**Type:** `float`

**Optional:** Yes

**Default:** 0

### snap_end

**Type:** `float`

**Optional:** Yes

**Default:** 0

### snap_end_arm_extent_multiplier

**Type:** `float`

**Optional:** Yes

**Default:** 0

### name

**Type:** `string`

**Optional:** Yes

**Default:** ""

### dying_effect

**Type:** `CranePartDyingEffect`

**Optional:** Yes

### relative_position

**Type:** `Vector3D`

**Optional:** Yes

### relative_position_grappler

**Type:** `Vector3D`

**Optional:** Yes

### static_length

**Type:** `Vector3D`

**Optional:** Yes

### extendable_length

**Type:** `Vector3D`

**Optional:** Yes

### static_length_grappler

**Type:** `Vector3D`

**Optional:** Yes

### extendable_length_grappler

**Type:** `Vector3D`

**Optional:** Yes

### sprite

**Type:** `Sprite`

**Optional:** Yes

### rotated_sprite

Only loaded if `sprite` is not defined.

**Type:** `RotatedSprite`

**Optional:** Yes

### sprite_shadow

**Type:** `Sprite`

**Optional:** Yes

### rotated_sprite_shadow

Only loaded if `sprite_shadow` is not defined.

**Type:** `RotatedSprite`

**Optional:** Yes

### sprite_reflection

**Type:** `Sprite`

**Optional:** Yes

### rotated_sprite_reflection

Only loaded if `sprite_reflection` is not defined.

**Type:** `RotatedSprite`

**Optional:** Yes

### layer

**Type:** `int8`

**Optional:** Yes

**Default:** 0

