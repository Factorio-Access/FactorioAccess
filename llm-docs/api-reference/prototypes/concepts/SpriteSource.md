# SpriteSource

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### filename

The path to the sprite file to use.

**Type:** `FileName`

**Required:** Yes

### size

The width and height of the sprite. If this is a tuple, the first member of the tuple is the width and the second is the height. Otherwise the size is both width and height. Width and height may only be in the range of 0-4096.

**Type:** `SpriteSizeType` | (`SpriteSizeType`, `SpriteSizeType`)

**Optional:** Yes

### width

Mandatory if `size` is not defined.

Width of the picture in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

### height

Mandatory if `size` is not defined.

Height of the picture in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

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

### position

Loaded only when `x` and `y` are both `0`. The first member of the tuple is `x` and the second is `y`.

**Type:** (`SpriteSizeType`, `SpriteSizeType`)

**Optional:** Yes

### load_in_minimal_mode

Minimal mode is entered when mod loading fails. You are in it when you see the gray box after (part of) the loading screen that tells you a mod error. Modders can ignore this property.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### premul_alpha

Whether alpha should be pre-multiplied.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_forced_downscale

If `true`, the sprite may be downsampled to half its size on load even when 'Sprite quality' graphics setting is set to 'High'. Whether downsampling happens depends on detected hardware and other graphics settings.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

