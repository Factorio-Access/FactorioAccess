# AnimationPrototype

Specifies an animation that can be used with [LuaRendering::draw_animation](runtime:LuaRendering::draw_animation) at runtime.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Name of the animation. Can be used with [LuaRendering::draw_animation](runtime:LuaRendering::draw_animation) at runtime.

#### type

**Type:** `animation`



### Optional Properties

#### allow_forced_downscale

**Type:** `boolean`

Only loaded if `layers` is not defined.

If `true`, the sprite may be downsampled to half its size on load even when 'Sprite quality' graphics setting is set to 'High'. Whether downsampling happens depends on detected hardware and other graphics settings.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### animation_speed

**Type:** `float`

Only loaded if `layers` is not defined.

Modifier of the animation playing speed, the default of `1` means one animation frame per tick (60 fps). The speed of playing can often vary depending on the usage (output of steam engine for example). Has to be greater than `0`.

If `layers` are used, the `animation_speed` only has to be defined in one layer. All layers will run at the same speed.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### apply_runtime_tint

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### apply_special_effect

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### blend_mode

**Type:** `BlendMode`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 'normal'}`

#### dice

**Type:** `uint8`

Only loaded if `layers` is not defined.

#### dice_x

**Type:** `uint8`

Only loaded if `layers` is not defined.

#### dice_y

**Type:** `uint8`

Only loaded if `layers` is not defined.

#### draw_as_glow

**Type:** `boolean`

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_light`.

Draws first as a normal sprite, then again as a light layer. See [https://forums.factorio.com/91682](https://forums.factorio.com/91682).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### draw_as_light

**Type:** `boolean`

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### draw_as_shadow

**Type:** `boolean`

Only loaded if `layers` is not defined.

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_glow` and `draw_as_light`.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### filename

**Type:** `FileName`

Only loaded if `layers` is not defined. Mandatory if neither `stripes` nor `filenames` are defined.

The path to the sprite file to use.

#### filenames

**Type:** ``FileName`[]`

Only loaded if neither `layers` nor `stripes` are defined.

#### flags

**Type:** `SpriteFlags`

Only loaded if `layers` is not defined.

#### frame_count

**Type:** `uint32`

Only loaded if `layers` is not defined.

Can't be `0`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### frame_sequence

**Type:** `AnimationFrameSequence`

Only loaded if `layers` is not defined.

#### generate_sdf

**Type:** `boolean`

Only loaded if `layers` is not defined.

Unused.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### height

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined. Mandatory if `size` is not defined.

Height of one frame in pixels, from 0-4096.

#### invert_colors

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### layers

**Type:** ``Animation`[]`

If this property is present, all Animation definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

`animation_speed` and `max_advance` of the first layer are used for all layers. All layers will run at the same speed.

If this property is present, all other properties besides `name` and `type` are ignored.

#### line_length

**Type:** `uint32`

Only loaded if `layers` is not defined.

Once the specified number of pictures is loaded, other pictures are loaded on other line. This is to allow having longer animations in matrix, to input files with too high width. The game engine limits the width of any input files to 8192px, so it is compatible with most graphics cards. `0` means that all the pictures are in one horizontal line.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### lines_per_file

**Type:** `uint32`

Only loaded if `layers` is not defined. Mandatory if `filenames` is defined.

#### load_in_minimal_mode

**Type:** `boolean`

Only loaded if `layers` is not defined.

Minimal mode is entered when mod loading fails. You are in it when you see the gray box after (part of) the loading screen that tells you a mod error. Modders can ignore this property.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### max_advance

**Type:** `float`

Only loaded if `layers` is not defined.

If `layers` are used, `max_advance` of the first layer is used for all layers.

Maximum amount of frames the animation can move forward in one update.

**Default:** `MAX_FLOAT`

#### mipmap_count

**Type:** `uint8`

Only loaded if `layers` is not defined.

Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.

Note that `mipmap_count` doesn't make sense in an animation, as it is not possible to layout mipmaps in a way that would load both the animation and the mipmaps correctly (besides animations with just one frame). See [here](https://forums.factorio.com/viewtopic.php?p=549058#p549058).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### position

**Type:** `[]`

Only loaded if `layers` is not defined.

Loaded only when `x` and `y` are both `0`. The first member of the tuple is `x` and the second is `y`.

#### premul_alpha

**Type:** `boolean`

Only loaded if `layers` is not defined.

Whether alpha should be pre-multiplied.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### priority

**Type:** `SpritePriority`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 'medium'}`

#### repeat_count

**Type:** `uint8`

Only loaded if `layers` is not defined.

How many times to repeat the animation to complete an animation cycle. E.g. if one layer is 10 frames, a second layer of 1 frame would need `repeat_count = 10` to match the complete cycle.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### rotate_shift

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### run_mode

**Type:** `AnimationRunMode`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 'forward'}`

#### scale

**Type:** `double`

Only loaded if `layers` is not defined.

Values other than `1` specify the scale of the sprite on default zoom. A scale of `2` means that the picture will be two times bigger on screen (and thus more pixelated).

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### shift

**Type:** `Vector`

Only loaded if `layers` is not defined.

The shift in tiles. `util.by_pixel()` can be used to divide the shift by 32 which is the usual pixel height/width of 1 tile in normal resolution. Note that 32 pixel tile height/width is not enforced anywhere - any other tile height or width is also possible.

**Default:** ``{0, 0}``

#### size

**Type:** 

Only loaded if `layers` is not defined.

The width and height of one frame. If this is a tuple, the first member of the tuple is the width and the second is the height. Otherwise the size is both width and height. Width and height may only be in the range of 0-4096.

#### slice

**Type:** `uint32`

Only loaded if `layers` is not defined and if `filenames` is defined.

**Default:** `Value of `frame_count``

#### stripes

**Type:** ``Stripe`[]`

Only loaded if `layers` is not defined.

#### surface

**Type:** `SpriteUsageSurfaceHint`

Only loaded if `layers` is not defined.

Provides hint to sprite atlas system, so it can try to put sprites that are intended to be used at the same locations to the same sprite atlas.

**Default:** `{'complex_type': 'literal', 'value': 'any'}`

#### tint

**Type:** `Color`

Only loaded if `layers` is not defined.

**Default:** ``{r=1, g=1, b=1, a=1}``

#### tint_as_overlay

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### usage

**Type:** `SpriteUsageHint`

Only loaded if `layers` is not defined.

Provides hint to sprite atlas system, so it can pack sprites that are related to each other to the same sprite atlas.

**Default:** `{'complex_type': 'literal', 'value': 'any'}`

#### width

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined. Mandatory if `size` is not defined.

Width of one frame in pixels, from 0-4096.

#### x

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Horizontal position of the animation in the source file in pixels.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### y

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Vertical position of the animation in the source file in pixels.

**Default:** `{'complex_type': 'literal', 'value': 0}`

