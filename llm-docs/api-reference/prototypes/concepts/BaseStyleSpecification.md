# BaseStyleSpecification

The abstract base of all [StyleSpecifications](prototype:StyleSpecification).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### parent

Name of a [StyleSpecification](prototype:StyleSpecification). This style inherits all property values from its parent.

Styles without a parent property default to the root style for their type. The exception to this are the root styles themselves, as they cannot have a parent set. Due to this, for root styles, some style properties are mandatory and behavior may be unexpected, such as an element not showing up because its size defaults to `0`.

**Type:** `string`

**Optional:** Yes

### horizontal_align

**Type:** `HorizontalAlign`

**Optional:** Yes

**Default:** "left"

### vertical_align

**Type:** `VerticalAlign`

**Optional:** Yes

**Default:** "top"

### ignored_by_search

**Type:** `boolean`

**Optional:** Yes

### never_hide_by_search

**Type:** `boolean`

**Optional:** Yes

### horizontally_stretchable

**Type:** `StretchRule`

**Optional:** Yes

**Default:** "auto"

### vertically_stretchable

**Type:** `StretchRule`

**Optional:** Yes

**Default:** "auto"

### horizontally_squashable

**Type:** `StretchRule`

**Optional:** Yes

**Default:** "auto"

### vertically_squashable

**Type:** `StretchRule`

**Optional:** Yes

**Default:** "auto"

### natural_size

If this is a tuple, the first member sets `natural_width` and the second sets `natural_height`. Otherwise, both `natural_width` and `natural_height` are set to the same value.

**Type:** `uint32` | (`uint32`, `uint32`)

**Optional:** Yes

### size

If this is a tuple, the first member sets `width`, and the second sets `height`. Otherwise, both `width` and `height` are set to the same value.

**Type:** `uint32` | (`uint32`, `uint32`)

**Optional:** Yes

### width

Sets `minimal_width`, `maximal_width` and `natural_width` to the same value.

**Type:** `uint32`

**Optional:** Yes

### minimal_width

Minimal width ensures that the widget will never be smaller than than that size. It can't be squashed to be smaller.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### maximal_width

Maximal width ensures that the widget will never be bigger than than that size. It can't be stretched to be bigger.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### natural_width

Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a different size.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### height

Sets `minimal_height`, `maximal_height` and `natural_height` to the same value.

**Type:** `uint32`

**Optional:** Yes

### minimal_height

Minimal height ensures that the widget will never be smaller than than that size. It can't be squashed to be smaller.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### maximal_height

Maximal height ensures that the widget will never be bigger than than that size. It can't be stretched to be bigger.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### natural_height

Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a different size.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### padding

Sets `top_padding`, `right_padding`, `bottom_padding` and `left_padding` to the same value.

**Type:** `int16`

**Optional:** Yes

### top_padding

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### right_padding

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### bottom_padding

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### left_padding

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### margin

Sets `top_margin`, `right_margin`, `bottom_margin` and `left_margin` to the same value.

**Type:** `int16`

**Optional:** Yes

### top_margin

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### right_margin

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### bottom_margin

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### left_margin

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### effect

Name of a custom GUI effect, which are hard-coded in the game's engine. Only has one option currently.

**Type:** `"compilatron-hologram"`

**Optional:** Yes

### effect_opacity

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### tooltip

**Type:** `LocalisedString`

**Optional:** Yes

## Examples

```
```
-- Adding a custom frame_style-type style via GuiStyle
data.raw["gui-style"]["default"]["custom_style_for_a_frame"] =
{
  type = "frame_style",
  parent = "frame",
  use_header_filler = false,
  drag_by_title = false
}
```
```

