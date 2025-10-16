# TileMainPictures

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### size

Only powers of 2 from 1 to 128 can be used. Square size of the tile arrangement this sprite is used for. Used to calculate the `width` and `height` of the sprite which cannot be set directly. (width or height) = size * 32 / scale.

**Type:** `uint32`

**Required:** Yes

### probability

Probability of 1x1 (size = 1) version of tile must be 1.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### weights

**Type:** Array[`double`]

**Optional:** Yes

