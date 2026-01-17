# RotatedAnimation

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

If this property is present, all RotatedAnimation definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

If this property is present, all other properties, including those inherited from AnimationParameters, are ignored.

**Type:** Array[`RotatedAnimation`]

**Optional:** Yes

### direction_count

Only loaded if `layers` is not defined.

The sequential animation instance is loaded equal to the entities direction within the `direction_count` setting.

Direction count to [defines.direction](runtime:defines.direction) (animation sequence number):

- `1`: North (1)

- `2`: North (1), South (2)

- `4`: North (1), East (2), South (3), West (4)

- `8`: North (1), Northeast (2), East (3), Southeast (4), South (5), Southwest (6), West (7), Northwest (8)

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### filename

Only loaded, and mandatory if `layers`, `stripes`, and `filenames` are not defined.

The path to the sprite file to use.

**Type:** `FileName`

**Optional:** Yes

### filenames

Only loaded if both `layers` and `stripes` are not defined.

**Type:** Array[`FileName`]

**Optional:** Yes

### lines_per_file

Only loaded if `layers` is not defined. Mandatory if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

### slice

Only loaded if `layers` is not defined. Mandatory if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

### still_frame

Only loaded if `layers` is not defined.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### counterclockwise

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### middle_orientation

Only loaded if `layers` is not defined.

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** 0.5

### orientation_range

Only loaded if `layers` is not defined.

Automatically clamped to be between `0` and `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### apply_projection

Used to fix the inconsistency of direction of the entity in 3d when rendered and direction on the screen (where the 45 degree angle for projection is used).

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### stripes

Only loaded if `layers` is not defined.

**Type:** Array[`Stripe`]

**Optional:** Yes

