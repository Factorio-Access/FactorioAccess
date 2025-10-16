# AnimationParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### size

The width and height of one frame. If this is a tuple, the first member of the tuple is the width and the second is the height. Otherwise the size is both width and height. Width and height may only be in the range of 0-4096.

**Type:** `SpriteSizeType` | (`SpriteSizeType`, `SpriteSizeType`)

**Optional:** Yes

### width

Mandatory if `size` is not defined.

Width of one frame in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

### height

Mandatory if `size` is not defined.

Height of one frame in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

### run_mode

**Type:** `AnimationRunMode`

**Optional:** Yes

**Default:** "forward"

### frame_count

Can't be `0`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### line_length

Specifies how many pictures are on each horizontal line in the image file. `0` means that all the pictures are in one horizontal line. Once the specified number of pictures are loaded from a line, the pictures from the next line are loaded. This is to allow having longer animations loaded in to Factorio's graphics matrix than the game engine's width limit of 8192px per input file. The restriction on input files is to be compatible with most graphics cards.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### animation_speed

Modifier of the animation playing speed, the default of `1` means one animation frame per tick (60 fps). The speed of playing can often vary depending on the usage (output of steam engine for example). Has to be greater than `0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### max_advance

Maximum amount of frames the animation can move forward in one update. Useful to cap the animation speed on entities where it is variable, such as car animations.

**Type:** `float`

**Optional:** Yes

**Default:** "MAX_FLOAT"

### repeat_count

How many times to repeat the animation to complete an animation cycle. E.g. if one layer is 10 frames, a second layer of 1 frame would need `repeat_count = 10` to match the complete cycle.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### dice

Number of slices this is sliced into when using the "optimized atlas packing" option. If you are a modder, you can just ignore this property. Example: If this is 4, the sprite will be sliced into a 4×4 grid.

**Type:** `uint8`

**Optional:** Yes

### dice_x

Same as `dice` above, but this specifies only how many slices there are on the x axis.

**Type:** `uint8`

**Optional:** Yes

### dice_y

Same as `dice` above, but this specifies only how many slices there are on the y axis.

**Type:** `uint8`

**Optional:** Yes

### frame_sequence

**Type:** `AnimationFrameSequence`

**Optional:** Yes

### mipmap_count

Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.

Note that `mipmap_count` doesn't make sense in an animation, as it is not possible to layout mipmaps in a way that would load both the animation and the mipmaps correctly (besides animations with just one frame). See [here](https://forums.factorio.com/viewtopic.php?p=549058#p549058).

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### generate_sdf

Unused.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

