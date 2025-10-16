# MaterialTextureParameters

Used by [TilePrototype](prototype:TilePrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### count

Frame count.

**Type:** `uint32`

**Required:** Yes

### picture

**Type:** `FileName`

**Required:** Yes

### scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### x

Horizontal position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### y

Vertical position of the sprite in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### line_length

Once the specified number of pictures is loaded, other pictures are loaded on other line. This is to allow having longer animations in matrix, to input files with too high width. The game engine limits the width of any input files to 8192px, so it is compatible with most graphics cards. 0 means that all the pictures are in one horizontal line.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

