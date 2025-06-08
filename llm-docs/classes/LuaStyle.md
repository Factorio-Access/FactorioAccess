# LuaStyle

Style of a GUI element. All of the attributes listed here may be `nil` if not available for a particular GUI element.

## Attributes

### badge_font

**Type:** `string`



### badge_horizontal_spacing

**Type:** `int`



### bar_width

**Type:** `uint`



### bottom_cell_padding

**Type:** `int`

Space between the table cell contents bottom and border.

### bottom_margin

**Type:** `int`



### bottom_padding

**Type:** `int`



### cell_padding

**Type:** `any`

Space between the table cell contents and border. Sets top/right/bottom/left cell paddings to this value.

### clicked_font_color

**Type:** `Color`



### clicked_vertical_offset

**Type:** `int`



### color

**Type:** `Color`



### column_alignments

**Type:** `LuaCustomTable<`uint`, `Alignment`>` _(read-only)_

Array containing the alignment for every column of this table element. Even though this property is marked as read-only, the alignment can be changed by indexing the LuaCustomTable, like so:

### default_badge_font_color

**Type:** `Color`



### disabled_badge_font_color

**Type:** `Color`



### disabled_font_color

**Type:** `Color`



### draw_grayscale_picture

**Type:** `boolean`



### extra_bottom_margin_when_activated

**Type:** `int`



### extra_bottom_padding_when_activated

**Type:** `int`



### extra_left_margin_when_activated

**Type:** `int`



### extra_left_padding_when_activated

**Type:** `int`



### extra_margin_when_activated

**Type:** `any`

Sets `extra_top/right/bottom/left_margin_when_activated` to this value.

An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.

### extra_padding_when_activated

**Type:** `any`

Sets `extra_top/right/bottom/left_padding_when_activated` to this value.

An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.

### extra_right_margin_when_activated

**Type:** `int`



### extra_right_padding_when_activated

**Type:** `int`



### extra_top_margin_when_activated

**Type:** `int`



### extra_top_padding_when_activated

**Type:** `int`



### font

**Type:** `string`



### font_color

**Type:** `Color`



### gui

**Type:** `LuaGui` _(read-only)_

Gui of the [LuaGuiElement](runtime:LuaGuiElement) of this style.

### height

**Type:** `any`

Sets both minimal and maximal height to the given value.

### horizontal_align

**Type:** 

Horizontal align of the inner content of the widget, if any.

### horizontal_spacing

**Type:** `int`

Horizontal space between individual cells.

### horizontally_squashable

**Type:** `boolean`

Whether the GUI element can be squashed (by maximal width of some parent element) horizontally. `nil` if this element does not support squashing.

This is mainly meant to be used for scroll-pane. The default value is false.

### horizontally_stretchable

**Type:** `boolean`

Whether the GUI element stretches its size horizontally to other elements. `nil` if this element does not support stretching.

### hovered_font_color

**Type:** `Color`



### left_cell_padding

**Type:** `int`

Space between the table cell contents left and border.

### left_margin

**Type:** `int`



### left_padding

**Type:** `int`



### margin

**Type:** `any`

Sets top/right/bottom/left margins to this value.

An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.

### maximal_height

**Type:** `int`

Maximal height ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.

### maximal_width

**Type:** `int`

Maximal width ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.

### minimal_height

**Type:** `int`

Minimal height ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.

### minimal_width

**Type:** `int`

Minimal width ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.

### name

**Type:** `string` _(read-only)_

Name of this style.

### natural_height

**Type:** `int`

Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.

### natural_width

**Type:** `int`

Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### padding

**Type:** `any`

Sets top/right/bottom/left paddings to this value.

An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.

### pie_progress_color

**Type:** `Color`



### rich_text_setting

**Type:** `defines.rich_text_setting`

How this GUI element handles rich text.

### right_cell_padding

**Type:** `int`

Space between the table cell contents right and border.

### right_margin

**Type:** `int`



### right_padding

**Type:** `int`



### selected_badge_font_color

**Type:** `Color`



### selected_clicked_font_color

**Type:** `Color`



### selected_font_color

**Type:** `Color`



### selected_hovered_font_color

**Type:** `Color`



### single_line

**Type:** `boolean`



### size

**Type:** `any`

Sets both width and height to the given value. Also accepts an array with two values, setting width to the first and height to the second one.

### stretch_image_to_widget_size

**Type:** `boolean`



### strikethrough_color

**Type:** `Color`



### top_cell_padding

**Type:** `int`

Space between the table cell contents top and border.

### top_margin

**Type:** `int`



### top_padding

**Type:** `int`



### use_header_filler

**Type:** `boolean`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### vertical_align

**Type:** 

Vertical align of the inner content of the widget, if any.

### vertical_spacing

**Type:** `int`

Vertical space between individual cells.

### vertically_squashable

**Type:** `boolean`

Whether the GUI element can be squashed (by maximal height of some parent element) vertically. `nil` if this element does not support squashing.

This is mainly meant to be used for scroll-pane. The default (parent) value for scroll pane is true, false otherwise.

### vertically_stretchable

**Type:** `boolean`

Whether the GUI element stretches its size vertically to other elements. `nil` if this element does not support stretching.

### width

**Type:** `any`

Sets both minimal and maximal width to the given value.

