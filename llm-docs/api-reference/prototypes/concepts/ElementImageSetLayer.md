# ElementImageSetLayer

If this is loaded as a Sprite, it gets used as `center`.

**Type:** `Struct` (see below for attributes) | `Sprite`

## Properties

*These properties apply when the value is a struct/table.*

### draw_type

Defines whether the border should be drawn inside the widget, which affects the padding and content size of the widget, or outside of the widget which doesn't affect size. The outer draw type is most commonly used for shadows, glows and insets.

**Type:** `"inner"` | `"outer"`

**Optional:** Yes

**Default:** "inner"

### type

**Type:** `"none"` | `"composition"`

**Optional:** Yes

**Default:** "`"none"` if this has no other properties, otherwise `"composition"`"

### tint

Only loaded if `type` is `"composition"`.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1, a=1}`"

### center

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### left

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### left_top

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### left_bottom

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### right

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### right_top

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### right_bottom

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### top

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### bottom

Only loaded if `type` is `"composition"`.

**Type:** `Sprite`

**Optional:** Yes

### corner_size

If this is a tuple, the first member of the tuple is width and the second is height. Otherwise the size is both width and height.

Only loaded if `type` is `"composition"`.

**Type:** `uint16` | (`uint16`, `uint16`)

**Optional:** Yes

### filename

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "The `default_tileset` set in GuiStyle"

### position

Mandatory if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `MapPosition`

**Optional:** Yes

### load_in_minimal_mode

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### top_width

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### bottom_width

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### left_height

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### right_height

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### center_width

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### center_height

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 1

### scale

Only loaded if `corner_size` is defined. Only loaded if `type` is `"composition"`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### top_border

Only loaded if `type` is `"composition"`.

**Type:** `int32`

**Optional:** Yes

### right_border

Only loaded if `type` is `"composition"`.

**Type:** `int32`

**Optional:** Yes

### bottom_border

Only loaded if `type` is `"composition"`.

**Type:** `int32`

**Optional:** Yes

### left_border

Only loaded if `type` is `"composition"`.

**Type:** `int32`

**Optional:** Yes

### border

Sets `top_border`, `right_border`, `bottom_border` and `left_border`.

Only loaded if `corner_size` is not defined. Only loaded if `type` is `"composition"`.

**Type:** `int32`

**Optional:** Yes

### stretch_monolith_image_to_size

Only loaded if `type` is `"composition"`.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### left_tiling

Tiling is used to make a side (not corner) texture repeat instead of being stretched.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### right_tiling

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### top_tiling

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### bottom_tiling

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### center_tiling_vertical

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### center_tiling_horizontal

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### overall_tiling_horizontal_size

Overall tiling is used to make the overall texture repeat instead of being stretched.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### overall_tiling_horizontal_spacing

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### overall_tiling_horizontal_padding

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### overall_tiling_vertical_size

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### overall_tiling_vertical_spacing

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### overall_tiling_vertical_padding

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### custom_horizontal_tiling_sizes

**Type:** Array[`uint32`]

**Optional:** Yes

### opacity

**Type:** `double`

**Optional:** Yes

**Default:** 1

### background_blur

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### background_blur_sigma

**Type:** `float`

**Optional:** Yes

**Default:** "`4` if `background_blur` is `true`"

### top_outer_border_shift

**Type:** `int32`

**Optional:** Yes

**Default:** 0

### bottom_outer_border_shift

**Type:** `int32`

**Optional:** Yes

**Default:** 0

### right_outer_border_shift

**Type:** `int32`

**Optional:** Yes

**Default:** 0

### left_outer_border_shift

**Type:** `int32`

**Optional:** Yes

**Default:** 0

