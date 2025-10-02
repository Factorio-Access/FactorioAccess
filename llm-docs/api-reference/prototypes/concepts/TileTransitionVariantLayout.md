# TileTransitionVariantLayout

The properties from the parent TileSpriteLayoutVariant provide defaults for the properties defined here.

The `{inner_corner | outer_corner | side | double_side | u_transition | o_transition}_*` properties provide defaults for the properties inside the specific variant. They are used to specify select values for the variant without creating the table for the variant.

These various ways to define the variants are also shown in the examples below.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### x_offset

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### y_offset

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### inner_corner

Defaults to the values set in the `inner_corner_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### outer_corner

Defaults to the values set in the `outer_corner_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### side

Defaults to the values set in the `side_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### double_side

Defaults to the values set in the `double_side_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### u_transition

Defaults to the values set in the `u_transition_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### o_transition

Defaults to the values set in the `o_transition_*` properties.

**Type:** `TileSpriteLayoutVariant`

**Optional:** Yes

### inner_corner_scale

**Type:** `float`

**Optional:** Yes

### inner_corner_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### inner_corner_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### inner_corner_tile_height

**Type:** `uint8`

**Optional:** Yes

### inner_corner_line_length

**Type:** `uint8`

**Optional:** Yes

### inner_corner_count

**Type:** `uint8`

**Optional:** Yes

### outer_corner_scale

**Type:** `float`

**Optional:** Yes

### outer_corner_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### outer_corner_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### outer_corner_tile_height

**Type:** `uint8`

**Optional:** Yes

### outer_corner_line_length

**Type:** `uint8`

**Optional:** Yes

### outer_corner_count

**Type:** `uint8`

**Optional:** Yes

### side_scale

**Type:** `float`

**Optional:** Yes

### side_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### side_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### side_tile_height

**Type:** `uint8`

**Optional:** Yes

### side_line_length

**Type:** `uint8`

**Optional:** Yes

### side_count

**Type:** `uint8`

**Optional:** Yes

### double_side_scale

**Type:** `float`

**Optional:** Yes

### double_side_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### double_side_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### double_side_tile_height

**Type:** `uint8`

**Optional:** Yes

### double_side_line_length

**Type:** `uint8`

**Optional:** Yes

### double_side_count

**Type:** `uint8`

**Optional:** Yes

### u_transition_scale

**Type:** `float`

**Optional:** Yes

### u_transition_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### u_transition_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### u_transition_tile_height

**Type:** `uint8`

**Optional:** Yes

### u_transition_line_length

**Type:** `uint8`

**Optional:** Yes

### u_transition_count

**Type:** `uint8`

**Optional:** Yes

### o_transition_scale

**Type:** `float`

**Optional:** Yes

### o_transition_x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### o_transition_y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### o_transition_tile_height

**Type:** `uint8`

**Optional:** Yes

### o_transition_line_length

**Type:** `uint8`

**Optional:** Yes

### o_transition_count

**Type:** `uint8`

**Optional:** Yes

## Examples

```
```
-- longest version, using TileSpriteLayoutVariant tables for each variant
{
  inner_corner =
  {
    scale = 0.5,
    count = 8,
  },
  outer_corner =
  {
    scale = 0.5,
    count = 8,
    x = 576
  },
  u_transition  =
  {
    scale = 0.5,
    count = 1,
    x = 1728
  },
  [...]
}
```
```

```
```
-- The above version is quite verbose, scale is duplicated in each variant layout.
-- So it is possible to define default value of each property of TileSpriteLayoutVariant directly in TileTransitionVariantLayout:
{
  scale = 0.5,
  inner_corner =
  {
    count = 8,
  },
  outer_corner =
  {
    count = 8,
    x = 576
  },
  u_transition  =
  {
    count = 1,
    x = 1728
  },
  [...]
}
```
```

```
```
-- The above version is creating a table to just specify inner_corner has 8 count. It can be shorter by using variant prefix properties:
{
  scale = 0.5,
  inner_corner_count = 8,
  outer_corner_count = 8,
  u_transition_count = 1,
  outer_corner_x = 576,
  u_transition_x = 1728,
  [...]
}
```
```

