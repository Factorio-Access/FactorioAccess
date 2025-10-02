# TileSpriteLayoutVariant

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### spritesheet

**Type:** `FileName`

**Optional:** Yes

### scale

**Type:** `float`

**Optional:** Yes

### x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

### tile_height

Height of the transition sprite in tiles. May be 1 or 2. It is forced to 1 for mask layers and for o_transition. A tile is considered 32px with scale 1 (so 64px with scale 0.5). Shift of the sprite will be adjusted such that the top 1x1 tile is centered on a tile being drawn (so it will be 
```
{0, 0.5*(tile_height - 1)}
```
) It can be anything between 1 to 8 for `background` layer if `draw_background_layer_under_tiles` is set to true.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### line_length

Once the specified number of pictures is loaded, other pictures are loaded on other line. This is to allow having longer animations in matrix, to input files with too high width. The game engine limits the width of any input files to 8192px, so it is compatible with most graphics cards. 0 means that all the pictures are in one horizontal line.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### count

Frame count.

**Type:** `uint8`

**Optional:** Yes

