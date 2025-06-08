# SpritePrototype

Specifies an image that can be used with [SpritePath](runtime:SpritePath) at runtime.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Name of the sprite. Can be used as a [SpritePath](runtime:SpritePath) at runtime.

#### type

**Type:** `sprite`



### Optional Properties

#### allow_forced_downscale

**Type:** `boolean`

Only loaded if `layers` is not defined.

If `true`, the sprite may be downsampled to half its size on load even when 'Sprite quality' graphics setting is set to 'High'. Whether downsampling happens depends on detected hardware and other graphics settings.

**Default:** `{'complex_type': 'literal', 'value': False}`

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

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Number of slices this is sliced into when using the "optimized atlas packing" option. If you are a modder, you can just ignore this property. Example: If this is 4, the sprite will be sliced into a 4x4 grid.

#### dice_x

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the x axis.

#### dice_y

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the y axis.

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

Only loaded, and mandatory if `layers` is not defined.

The path to the sprite file to use.

#### flags

**Type:** `SpriteFlags`

Only loaded if `layers` is not defined.

#### generate_sdf

**Type:** `boolean`

Only loaded if `layers` is not defined.

Unused.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### height

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined. Mandatory if `size` is not defined.

Height of the picture in pixels, from 0-4096.

#### invert_colors

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### layers

**Type:** ``Sprite`[]`

If this property is present, all Sprite definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

If this property is present, all other properties besides `name` and `type` are ignored.

#### load_in_minimal_mode

**Type:** `boolean`

Only loaded if `layers` is not defined.

Minimal mode is entered when mod loading fails. You are in it when you see the gray box after (part of) the loading screen that tells you a mod error. Modders can ignore this property.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### mipmap_count

**Type:** `uint8`

Only loaded if `layers` is not defined.

Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`.

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

#### rotate_shift

**Type:** `boolean`

Only loaded if `layers` is not defined.

**Default:** `{'complex_type': 'literal', 'value': False}`

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

The width and height of the sprite. If this is a tuple, the first member of the tuple is the width and the second is the height. Otherwise the size is both width and height. Width and height may only be in the range of 0-4096.

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

Width of the picture in pixels, from 0-4096.

#### x

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Horizontal position of the sprite in the source file in pixels.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### y

**Type:** `SpriteSizeType`

Only loaded if `layers` is not defined.

Vertical position of the sprite in the source file in pixels.

**Default:** `{'complex_type': 'literal', 'value': 0}`

