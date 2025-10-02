# TileTransitionSpritesheetLayout

The properties from the parent TileSpriteLayoutVariant provide defaults for the TileTransitionVariantLayouts.

The `{inner_corner | outer_corner | side | double_side | u_transition | o_transition}_*` properties provide defaults for the corresponding properties in the TileTransitionVariantLayouts. They are used when the TileTransitionVariantLayouts have the same layout. See the example below.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### overlay

Only loaded if [TileTransitions::overlay_layout](prototype:TileTransitions::overlay_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### mask

Only loaded if [TileTransitions::mask_layout](prototype:TileTransitions::mask_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### background

Only loaded if [TileTransitions::background_layout](prototype:TileTransitions::background_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### background_mask

Only loaded if [TileTransitions::background_mask_layout](prototype:TileTransitions::background_mask_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### effect_map

Only loaded if [TileTransitions::effect_map_layout](prototype:TileTransitions::effect_map_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### lightmap

Only loaded if [TileTransitions::lightmap_layout](prototype:TileTransitions::lightmap_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### auxiliary_effect_mask

Only loaded if [TileTransitions::auxiliary_effect_mask_layout](prototype:TileTransitions::auxiliary_effect_mask_layout) is not defined in the TileTransitions that load this.

**Type:** `TileTransitionVariantLayout`

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
-- all the layers use the same layout, at different offsets inside the spritesheet
layout =
{
  scale = 0.5,
  inner_corner_count = 8,
  outer_corner_count = 8,
  o_transition_count = 1,
  outer_corner_x = 576,
  u_transition_x = 1728,

  overlay = { y_offset = 0 },  -- 0 is default, but by defining overlay property, we enable the layer
  mask = { y_offset = 512 },
  background = { y_offset = 1024 }
}
```
```

