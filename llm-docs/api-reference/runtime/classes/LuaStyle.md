# LuaStyle

Style of a GUI element. All of the attributes listed here may be `nil` if not available for a particular GUI element.

## Attributes

### gui

Gui of the [LuaGuiElement](runtime:LuaGuiElement) of this style.

**Read type:** `LuaGui`

### name

Name of this style.

**Read type:** `string`

### minimal_width

Minimal width ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.

**Read type:** `int32`

**Write type:** `int32`

### maximal_width

Maximal width ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.

**Read type:** `int32`

**Write type:** `int32`

### minimal_height

Minimal height ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.

**Read type:** `int32`

**Write type:** `int32`

### maximal_height

Maximal height ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.

**Read type:** `int32`

**Write type:** `int32`

### natural_width

Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.

**Read type:** `int32`

**Write type:** `int32`

### natural_height

Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.

**Read type:** `int32`

**Write type:** `int32`

### top_padding

**Read type:** `int32`

**Write type:** `int32`

### right_padding

**Read type:** `int32`

**Write type:** `int32`

### bottom_padding

**Read type:** `int32`

**Write type:** `int32`

### left_padding

**Read type:** `int32`

**Write type:** `int32`

### top_margin

**Read type:** `int32`

**Write type:** `int32`

### right_margin

**Read type:** `int32`

**Write type:** `int32`

### bottom_margin

**Read type:** `int32`

**Write type:** `int32`

### left_margin

**Read type:** `int32`

**Write type:** `int32`

### horizontal_align

Horizontal align of the inner content of the widget, if any.

**Read type:** `"left"` | `"center"` | `"right"`

**Write type:** `"left"` | `"center"` | `"right"`

**Optional:** Yes

### vertical_align

Vertical align of the inner content of the widget, if any.

**Read type:** `"top"` | `"center"` | `"bottom"`

**Write type:** `"top"` | `"center"` | `"bottom"`

**Optional:** Yes

### font_color

**Read type:** `Color`

**Write type:** `Color`

### font

**Read type:** `string`

**Write type:** `string`

### top_cell_padding

Space between the table cell contents top and border.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle

### right_cell_padding

Space between the table cell contents right and border.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle

### bottom_cell_padding

Space between the table cell contents bottom and border.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle

### left_cell_padding

Space between the table cell contents left and border.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle

### horizontally_stretchable

Whether the GUI element stretches its size horizontally to other elements. `nil` if this element does not support stretching.

**Read type:** `boolean`

**Write type:** `boolean`

**Optional:** Yes

### vertically_stretchable

Whether the GUI element stretches its size vertically to other elements. `nil` if this element does not support stretching.

**Read type:** `boolean`

**Write type:** `boolean`

**Optional:** Yes

### horizontally_squashable

Whether the GUI element can be squashed (by maximal width of some parent element) horizontally. `nil` if this element does not support squashing.

This is mainly meant to be used for scroll-pane. The default value is false.

**Read type:** `boolean`

**Write type:** `boolean`

**Optional:** Yes

### vertically_squashable

Whether the GUI element can be squashed (by maximal height of some parent element) vertically. `nil` if this element does not support squashing.

This is mainly meant to be used for scroll-pane. The default (parent) value for scroll pane is true, false otherwise.

**Read type:** `boolean`

**Write type:** `boolean`

**Optional:** Yes

### rich_text_setting

How this GUI element handles rich text.

**Read type:** `defines.rich_text_setting`

**Write type:** `defines.rich_text_setting`

**Subclasses:** LuaLabelStyle, LuaTextBoxStyle

### hovered_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle, LuaLabelStyle

### clicked_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle, LuaLabelStyle

### disabled_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle, LuaTabStyle, LuaLabelStyle, LuaTextBoxStyle

### pie_progress_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle

### clicked_vertical_offset

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaButtonStyle

### selected_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle

### selected_hovered_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle

### selected_clicked_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle

### strikethrough_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaButtonStyle

### draw_grayscale_picture

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** LuaButtonStyle

### horizontal_spacing

Horizontal space between individual cells.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle, LuaFlowStyle, LuaHorizontalFlowStyle

### vertical_spacing

Vertical space between individual cells.

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle, LuaTabbedPaneStyle

### use_header_filler

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** LuaFrameStyle

### bar_width

**Read type:** `uint32`

**Write type:** `uint32`

**Subclasses:** LuaProgressBarStyle

### color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** LuaProgressBarStyle

### column_alignments

Array containing the alignment for every column of this table element. Even though this property is marked as read-only, the alignment can be changed by indexing the LuaCustomTable, like so:

**Read type:** LuaCustomTable[`uint32`, `Alignment`]

### single_line

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** LabelStyle

### extra_top_padding_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_bottom_padding_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_left_padding_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_right_padding_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_top_margin_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_bottom_margin_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_left_margin_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_right_margin_when_activated

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** ScrollPaneStyle

### extra_padding_when_activated

Sets `extra_top/right/bottom/left_padding_when_activated` to this value.

An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.

**Write type:** `int32` | Array[`int32`]

### extra_margin_when_activated

Sets `extra_top/right/bottom/left_margin_when_activated` to this value.

An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.

**Write type:** `int32` | Array[`int32`]

### stretch_image_to_widget_size

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ImageStyle

### badge_font

**Read type:** `string`

**Write type:** `string`

**Subclasses:** TabStyle

### badge_horizontal_spacing

**Read type:** `int32`

**Write type:** `int32`

**Subclasses:** TabStyle

### default_badge_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** TabStyle

### selected_badge_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** TabStyle

### disabled_badge_font_color

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** TabStyle

### width

Sets both minimal and maximal width to the given value.

**Write type:** `int32`

### height

Sets both minimal and maximal height to the given value.

**Write type:** `int32`

### size

Sets both width and height to the given value. Also accepts an array with two values, setting width to the first and height to the second one.

**Write type:** `int32` | Array[`int32`]

### padding

Sets top/right/bottom/left paddings to this value.

An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.

**Write type:** `int32` | Array[`int32`]

### margin

Sets top/right/bottom/left margins to this value.

An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.

**Write type:** `int32` | Array[`int32`]

### cell_padding

Space between the table cell contents and border. Sets top/right/bottom/left cell paddings to this value.

**Write type:** `int32`

**Subclasses:** LuaTableStyle

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

