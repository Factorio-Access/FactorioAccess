# RotatedSprite

Specifies series of sprites used to visualize different rotations of the object.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

If this property is present, all RotatedSprite definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

If this property is present, all other properties, including those inherited from SpriteParameters, are ignored.

**Type:** Array[`RotatedSprite`]

**Optional:** Yes

### direction_count

Only loaded, and mandatory if `layers` is not defined.

Count of direction (frames) specified.

**Type:** `uint16`

**Optional:** Yes

### filename

Only loaded if `layers` is not defined.

The path to the sprite file to use.

**Type:** `FileName`

**Optional:** Yes

### filenames

Only loaded, and mandatory if both `layers` and `filename` are not defined.

**Type:** Array[`FileName`]

**Optional:** Yes

### lines_per_file

Only loaded if `layers` is not defined. Mandatory if `filenames` is defined.

**Type:** `uint64`

**Optional:** Yes

**Default:** 0

### dice

Only loaded if `layers` is not defined.

Number of slices this is sliced into when using the "optimized atlas packing" option. If you are a modder, you can just ignore this property. Example: If this is 4, the sprite will be sliced into a 4x4 grid.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_x

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the x axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_y

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the y axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

### generate_sdf

Only loaded if `layers` is not defined.

Unused.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### back_equals_front

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_projection

Only loaded if `layers` is not defined.

Used to fix the inconsistency of direction of the entity in 3d when rendered and direction on the screen (where the 45 degree angle for projection is used).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### counterclockwise

Only loaded if `layers` is not defined.

Set to `true` to indicate sprites in the spritesheet are in counterclockwise order.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### line_length

Only loaded if `layers` is not defined.

Once the specified number of pictures is loaded, other pictures are loaded on other line. This is to allow having more sprites in matrix, to input files with too high width. The game engine limits the width of any input files to 8192px, so it is compatible with most graphics cards. 0 means that all the pictures are in one horizontal line.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### allow_low_quality_rotation

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### frames

A list of overrides and customizations for each specific frame within the rotated sprite. This can be used to adjust each individual frame's width, height, and other properties. If this property is present, then it must contain at least as many `RotatedSpriteFrame` as there are sprites in this RotatedSprite.

**Type:** Array[`RotatedSpriteFrame`]

**Optional:** Yes

## Examples

```
```
pictures =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/radar/radar.png",
      priority = "low",
      width = 196,
      height = 254,
      apply_projection = false,
      direction_count = 64,
      line_length = 8,
      shift = util.by_pixel(1, -16),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/radar/radar-shadow.png",
      priority = "low",
      width = 343,
      height = 186,
      apply_projection = false,
      direction_count = 64,
      line_length = 8,
      shift = util.by_pixel(39.25,3),
      draw_as_shadow = true,
      scale = 0.5
    }
  }
}
```
```

