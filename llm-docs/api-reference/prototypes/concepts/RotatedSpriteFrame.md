# RotatedSpriteFrame

Specifies frame-specific properties of an individual sprite within a RotatedSprite set. Some properties are absolute values, and some are relative and inherited from the parent RotatedSprite prototype definition.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### width

Width of the sprite in pixels, from 0-4096. If not defined, inherits the width of the parent RotatedSprite.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** "inherited width"

### height

Height of the sprite in pixels, from 0-4096. If not defined, inherits the height of the parent RotatedSprite.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** "inherited height"

### x

The horizontal offset of the sprite relative to its specific frame within the parent RotatedSprite.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### y

The vertical offset of the sprite relative to its specific frame within the parent RotatedSprite.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### shift

The shift in tiles of this specific frame, relative to the shift of the parent RotatedSprite. `util.by_pixel()` can be used to divide the shift by 32 which is the usual pixel height/width of 1 tile in normal resolution. Note that 32 pixel tile height/width is not enforced anywhere - any other tile height or width is also possible.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

