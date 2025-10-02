# AnimationPrototype

Specifies an animation that can be used with [LuaRendering::draw_animation](runtime:LuaRendering::draw_animation) at runtime.

**Type name:** `animation`

## Properties

### type

**Type:** `"animation"`

**Required:** Yes

### name

Name of the animation. Can be used with [LuaRendering::draw_animation](runtime:LuaRendering::draw_animation) at runtime.

**Type:** `string`

**Required:** Yes

### layers

If this property is present, all Animation definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

`animation_speed` and `max_advance` of the first layer are used for all layers. All layers will run at the same speed.

If this property is present, all other properties besides `name` and `type` are ignored.

**Type:** Array[`Animation`]

**Optional:** Yes

### filename

Only loaded if `layers` is not defined. Mandatory if neither `stripes` nor `filenames` are defined.

The path to the sprite file to use.

**Type:** `FileName`

**Optional:** Yes

### priority

Only loaded if `layers` is not defined.

**Type:** `SpritePriority`

**Optional:** Yes

**Default:** "medium"

### flags

Only loaded if `layers` is not defined.

**Type:** `SpriteFlags`

**Optional:** Yes

### size

Only loaded if `layers` is not defined.

The width and height of one frame. If this is a tuple, the first member of the tuple is the width and the second is the height. Otherwise the size is both width and height. Width and height may only be in the range of 0-4096.

**Type:** `SpriteSizeType` | (`SpriteSizeType`, `SpriteSizeType`)

**Optional:** Yes

### width

Only loaded if `layers` is not defined. Mandatory if `size` is not defined.

Width of one frame in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

### height

Only loaded if `layers` is not defined. Mandatory if `size` is not defined.

Height of one frame in pixels, from 0-4096.

**Type:** `SpriteSizeType`

**Optional:** Yes

### x

Only loaded if `layers` is not defined.

Horizontal position of the animation in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### y

Only loaded if `layers` is not defined.

Vertical position of the animation in the source file in pixels.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 0

### position

Only loaded if `layers` is not defined.

Loaded only when `x` and `y` are both `0`. The first member of the tuple is `x` and the second is `y`.

**Type:** (`SpriteSizeType`, `SpriteSizeType`)

**Optional:** Yes

### shift

Only loaded if `layers` is not defined.

The shift in tiles. `util.by_pixel()` can be used to divide the shift by 32 which is the usual pixel height/width of 1 tile in normal resolution. Note that 32 pixel tile height/width is not enforced anywhere - any other tile height or width is also possible.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

### rotate_shift

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_special_effect

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scale

Only loaded if `layers` is not defined.

Values other than `1` specify the scale of the sprite on default zoom. A scale of `2` means that the picture will be two times bigger on screen (and thus more pixelated).

**Type:** `double`

**Optional:** Yes

**Default:** 1

### draw_as_shadow

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_glow` and `draw_as_light`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### draw_as_glow

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_light`.

Draws first as a normal sprite, then again as a light layer. See [https://forums.factorio.com/91682](https://forums.factorio.com/91682).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### draw_as_light

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### mipmap_count

Only loaded if `layers` is not defined.

Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.

Note that `mipmap_count` doesn't make sense in an animation, as it is not possible to layout mipmaps in a way that would load both the animation and the mipmaps correctly (besides animations with just one frame). See [here](https://forums.factorio.com/viewtopic.php?p=549058#p549058).

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### apply_runtime_tint

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tint_as_overlay

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### invert_colors

Only loaded if `layers` is not defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tint

Only loaded if `layers` is not defined.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1, a=1}`"

### blend_mode

Only loaded if `layers` is not defined.

**Type:** `BlendMode`

**Optional:** Yes

**Default:** "normal"

### load_in_minimal_mode

Only loaded if `layers` is not defined.

Minimal mode is entered when mod loading fails. You are in it when you see the gray box after (part of) the loading screen that tells you a mod error. Modders can ignore this property.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### premul_alpha

Only loaded if `layers` is not defined.

Whether alpha should be pre-multiplied.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_forced_downscale

Only loaded if `layers` is not defined.

If `true`, the sprite may be downsampled to half its size on load even when 'Sprite quality' graphics setting is set to 'High'. Whether downsampling happens depends on detected hardware and other graphics settings.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### generate_sdf

Only loaded if `layers` is not defined.

Unused.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### surface

Only loaded if `layers` is not defined.

Provides hint to sprite atlas system, so it can try to put sprites that are intended to be used at the same locations to the same sprite atlas.

**Type:** `SpriteUsageSurfaceHint`

**Optional:** Yes

**Default:** "any"

### usage

Only loaded if `layers` is not defined.

Provides hint to sprite atlas system, so it can pack sprites that are related to each other to the same sprite atlas.

**Type:** `SpriteUsageHint`

**Optional:** Yes

**Default:** "any"

### run_mode

Only loaded if `layers` is not defined.

**Type:** `AnimationRunMode`

**Optional:** Yes

**Default:** "forward"

### frame_count

Only loaded if `layers` is not defined.

Can't be `0`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### line_length

Only loaded if `layers` is not defined.

Once the specified number of pictures is loaded, other pictures are loaded on other line. This is to allow having longer animations in matrix, to input files with too high width. The game engine limits the width of any input files to 8192px, so it is compatible with most graphics cards. `0` means that all the pictures are in one horizontal line.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### animation_speed

Only loaded if `layers` is not defined.

Modifier of the animation playing speed, the default of `1` means one animation frame per tick (60 fps). The speed of playing can often vary depending on the usage (output of steam engine for example). Has to be greater than `0`.

If `layers` are used, the `animation_speed` only has to be defined in one layer. All layers will run at the same speed.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### max_advance

Only loaded if `layers` is not defined.

If `layers` are used, `max_advance` of the first layer is used for all layers.

Maximum amount of frames the animation can move forward in one update.

**Type:** `float`

**Optional:** Yes

**Default:** "MAX_FLOAT"

### repeat_count

Only loaded if `layers` is not defined.

How many times to repeat the animation to complete an animation cycle. E.g. if one layer is 10 frames, a second layer of 1 frame would need `repeat_count = 10` to match the complete cycle.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### dice

Only loaded if `layers` is not defined.

**Type:** `uint8`

**Optional:** Yes

### dice_x

Only loaded if `layers` is not defined.

**Type:** `uint8`

**Optional:** Yes

### dice_y

Only loaded if `layers` is not defined.

**Type:** `uint8`

**Optional:** Yes

### frame_sequence

Only loaded if `layers` is not defined.

**Type:** `AnimationFrameSequence`

**Optional:** Yes

### stripes

Only loaded if `layers` is not defined.

**Type:** Array[`Stripe`]

**Optional:** Yes

### filenames

Only loaded if neither `layers` nor `stripes` are defined.

**Type:** Array[`FileName`]

**Optional:** Yes

### slice

Only loaded if `layers` is not defined and if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `frame_count`"

### lines_per_file

Only loaded if `layers` is not defined. Mandatory if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

