# LuaGuiElement

An element of a custom GUI. This type is used to represent [any kind](runtime:GuiElementType) of a GUI element - labels, buttons and frames are all instances of this type. Just like [LuaEntity](runtime:LuaEntity), different kinds of elements support different attributes; attempting to access an attribute on an element that doesn't support it (for instance, trying to access the `column_count` of a `textfield`) will result in a runtime error.

For information on all supported GUI elements, see [GuiElementType](runtime:GuiElementType).

Each GUI element allows access to its children by having them as attributes. Thus, one can use the `parent.child` syntax to refer to children. Lua also supports the `parent["child"]` syntax to refer to the same element. This can be used in cases where the child has a name that isn't a valid Lua identifier.

## Attributes

### index

The index of this GUI element (unique amongst the GUI elements of a LuaPlayer).

**Read type:** `uint`

### gui

The GUI this element is a child of.

**Read type:** `LuaGui`

### parent

The direct parent of this element. `nil` if this is a top-level element.

**Read type:** `LuaGuiElement`

**Optional:** Yes

### name

The name of this element. `""` if no name was set.

**Read type:** `string`

**Write type:** `string`

### caption

The text displayed on this element. For frames, this is the "heading". For other elements, like buttons or labels, this is the content.

Whilst this attribute may be used on all elements without producing an error, it doesn't make sense for tables and flows as they won't display it.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

### value

How much this progress bar is filled. It is a value in the range `[0, 1]`.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** progressbar

### direction

Direction of this element's layout.

**Read type:** `GuiDirection`

**Subclasses:** frame, flow, line

### style

The style of this element. When read, this evaluates to a [LuaStyle](runtime:LuaStyle). For writing, it only accepts a string that specifies the textual identifier (prototype name) of the desired style.

**Read type:** `LuaStyle` | `string`

**Write type:** `LuaStyle` | `string`

### visible

Sets whether this GUI element is visible or completely hidden, taking no space in the layout.

**Read type:** `boolean`

**Write type:** `boolean`

### text

The text contained in this textfield or text-box.

**Read type:** `string`

**Write type:** `string`

**Subclasses:** textfield, text-box

### children_names

Names of all the children of this element. These are the identifiers that can be used to access the child as an attribute of this element.

**Read type:** Array[`string`]

### state

Is this checkbox or radiobutton checked?

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** checkbox, radiobutton

### player_index

Index into [LuaGameScript::players](runtime:LuaGameScript::players) specifying the player who owns this element.

**Read type:** `uint`

### sprite

The sprite to display on this sprite-button or sprite in the default state.

**Read type:** `SpritePath`

**Write type:** `SpritePath`

**Subclasses:** sprite-button, sprite

### resize_to_sprite

Whether the sprite widget should resize according to the sprite in it. Defaults to `true`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** sprite

### hovered_sprite

The sprite to display on this sprite-button when it is hovered.

**Read type:** `SpritePath`

**Write type:** `SpritePath`

**Subclasses:** sprite-button

### clicked_sprite

The sprite to display on this sprite-button when it is clicked.

**Read type:** `SpritePath`

**Write type:** `SpritePath`

**Subclasses:** sprite-button

### tooltip

The text to display when hovering over this element. Writing `""` or `nil` will disable the tooltip.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

### elem_tooltip

The element tooltip to display when hovering over this element, or `nil`.

**Read type:** `ElemID`

**Write type:** `ElemID`

**Optional:** Yes

### horizontal_scroll_policy

Policy of the horizontal scroll bar.

**Read type:** `ScrollPolicy`

**Write type:** `ScrollPolicy`

**Subclasses:** scroll-pane

### vertical_scroll_policy

Policy of the vertical scroll bar.

**Read type:** `ScrollPolicy`

**Write type:** `ScrollPolicy`

**Subclasses:** scroll-pane

### type

The type of this GUI element.

**Read type:** `GuiElementType`

### children

The child-elements of this GUI element.

**Read type:** Array[`LuaGuiElement`]

### items

The items in this dropdown or listbox.

**Read type:** Array[`LocalisedString`]

**Write type:** Array[`LocalisedString`]

**Subclasses:** drop-down, list-box

### selected_index

The selected index for this dropdown or listbox. Returns `0` if none is selected.

**Read type:** `uint`

**Write type:** `uint`

**Subclasses:** drop-down, list-box

### quality

The quality to be shown in the bottom left corner of this sprite-button, or `nil` to show nothing.

**Read type:** `LuaQualityPrototype`

**Write type:** `QualityID`

**Optional:** Yes

**Subclasses:** sprite-button

### number

The number to be shown in the bottom right corner of this sprite-button, or `nil` to show nothing.

**Read type:** `double`

**Write type:** `double`

**Optional:** Yes

**Subclasses:** sprite-button

### show_percent_for_small_numbers

Related to the number to be shown in the bottom right corner of this sprite-button. When set to `true`, numbers that are non-zero and smaller than one are shown as a percentage rather than the value. For example, `0.5` will be shown as `50%` instead.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** sprite-button

### location

The location of this widget when stored in [LuaGui::screen](runtime:LuaGui::screen). `nil` if not set or not in [LuaGui::screen](runtime:LuaGui::screen).

**Read type:** `GuiLocation`

**Write type:** `GuiLocation`

**Optional:** Yes

### auto_center

Whether this frame auto-centers on window resize when stored in [LuaGui::screen](runtime:LuaGui::screen).

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** frame

### badge_text

The text to display after the normal tab text (designed to work with numbers)

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** tab

### auto_toggle

Whether this button will automatically toggle when clicked.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** button, sprite-button

### toggled

Whether this button is currently toggled. When a button is toggled, it will use the `selected_graphical_set` and `selected_font_color` defined in its style.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** button, sprite-button

### game_controller_interaction

How this element should interact with game controllers.

**Read type:** `defines.game_controller_interaction`

**Write type:** `defines.game_controller_interaction`

### position

The position this camera or minimap is focused on, if any.

**Read type:** `MapPosition`

**Write type:** `MapPosition`

**Subclasses:** camera, minimap

### surface_index

The surface index this camera or minimap is using.

**Read type:** `uint`

**Write type:** `uint`

**Subclasses:** camera, minimap

### zoom

The zoom this camera or minimap is using. This value must be positive.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** camera, minimap

### minimap_player_index

The player index this minimap is using.

**Read type:** `uint`

**Write type:** `uint`

**Subclasses:** minimap

### force

The force this minimap is using, if any.

**Read type:** `string`

**Write type:** `string`

**Optional:** Yes

**Subclasses:** minimap

### elem_type

The elem type of this choose-elem-button.

**Read type:** `ElemType`

**Subclasses:** choose-elem-button

### elem_value

The elem value of this choose-elem-button, if any.

The `"signal"` type operates with [SignalID](runtime:SignalID).

The `"with-quality"` types operate with [PrototypeWithQuality](runtime:PrototypeWithQuality).

The remaining types use strings.

**Read type:** `string` | `SignalID` | `PrototypeWithQuality`

**Write type:** `string` | `SignalID` | `PrototypeWithQuality`

**Optional:** Yes

**Subclasses:** choose-elem-button

### elem_filters

The elem filters of this choose-elem-button, if any. The compatible type of filter is determined by `elem_type`.

Writing to this field does not change or clear the currently selected element.

**Read type:** `PrototypeFilter`

**Write type:** `PrototypeFilter`

**Optional:** Yes

**Subclasses:** choose-elem-button

### selectable

Whether the contents of this text-box are selectable. Defaults to `true`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** text-box

### word_wrap

Whether this text-box will word-wrap automatically. Defaults to `false`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** text-box

### read_only

Whether this text-box is read-only. Defaults to `false`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** text-box

### enabled

Whether this GUI element is enabled. Disabled GUI elements don't trigger events when clicked.

**Read type:** `boolean`

**Write type:** `boolean`

### ignored_by_interaction

Whether this GUI element is ignored by interaction. This makes clicks on this element 'go through' to the GUI element or even the game surface below it.

**Read type:** `boolean`

**Write type:** `boolean`

### locked

Whether this choose-elem-button can be changed by the player.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** choose-elem-button

### draw_vertical_lines

Whether this table should draw vertical grid lines.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** table

### draw_horizontal_lines

Whether this table should draw horizontal grid lines.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** table

### draw_horizontal_line_after_headers

Whether this table should draw a horizontal grid line below the first table row.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** table

### column_count

The number of columns in this table.

**Read type:** `uint`

**Subclasses:** table

### vertical_centering

Whether the content of this table should be vertically centered. Overrides [LuaStyle::column_alignments](runtime:LuaStyle::column_alignments). Defaults to `true`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** table

### slider_value

The value of this slider element.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** slider

### mouse_button_filter

The mouse button filters for this button or sprite-button.

**Read type:** `MouseButtonFlags`

**Write type:** `MouseButtonFlags`

**Subclasses:** button, sprite-button

### numeric

Whether this textfield is limited to only numeric characters.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** textfield

### allow_decimal

Whether this textfield (when in numeric mode) allows decimal numbers.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** textfield

### allow_negative

Whether this textfield (when in numeric mode) allows negative numbers.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** textfield

### is_password

Whether this textfield displays as a password field, which renders all characters as `*`.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** textfield

### lose_focus_on_confirm

Whether this textfield loses focus after [defines.events.on_gui_confirmed](runtime:defines.events.on_gui_confirmed) is fired.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** textfield

### drag_target

The `frame` that is being moved when dragging this GUI element, if any. This element needs to be a child of the `drag_target` at some level.

Only top-level elements in [LuaGui::screen](runtime:LuaGui::screen) can be `drag_target`s.

**Read type:** `LuaGuiElement`

**Write type:** `LuaGuiElement`

**Optional:** Yes

**Subclasses:** flow, frame, label, table, empty-widget

### selected_tab_index

The selected tab index for this tabbed pane, if any.

**Read type:** `uint`

**Write type:** `uint`

**Optional:** Yes

**Subclasses:** tabbed-pane

### tabs

The tabs and contents being shown in this tabbed-pane.

**Read type:** Array[`TabAndContent`]

**Subclasses:** tabbed-pane

### entity

The entity associated with this entity-preview, camera, minimap, if any.

**Read type:** `LuaEntity`

**Write type:** `LuaEntity`

**Optional:** Yes

**Subclasses:** entity-preview, camera, minimap

### anchor

The anchor for this relative widget, if any. Setting `nil` clears the anchor.

**Read type:** `GuiAnchor`

**Write type:** `GuiAnchor`

**Optional:** Yes

### tags

The tags associated with this LuaGuiElement.

**Read type:** `Tags`

**Write type:** `Tags`

### raise_hover_events

Whether this element will raise [on_gui_hover](runtime:on_gui_hover) and [on_gui_leave](runtime:on_gui_leave).

**Read type:** `boolean`

**Write type:** `boolean`

### switch_state

The switch state for this switch.

If [LuaGuiElement::allow_none_state](runtime:LuaGuiElement::allow_none_state) is false this can't be set to `"none"`.

**Read type:** `SwitchState`

**Write type:** `SwitchState`

**Subclasses:** switch

### allow_none_state

Whether the `"none"` state is allowed for this switch.

This can't be set to false if the current switch_state is 'none'.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** switch

### left_label_caption

The text shown for the left switch label.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** switch

### left_label_tooltip

The tooltip shown on the left switch label.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** switch

### right_label_caption

The text shown for the right switch label.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** switch

### right_label_tooltip

The tooltip shown on the right switch label.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** switch

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### add

Add a new child element to this GuiElement.

**Parameters:**

- `anchor` `GuiAnchor` *(optional)* - Where to position the child element when in the `relative` element.
- `caption` `LocalisedString` *(optional)* - Text displayed on the child element. For frames, this is their title. For other elements, like buttons or labels, this is the content. Whilst this attribute may be used on all elements, it doesn't make sense for tables and flows as they won't display it.
- `elem_tooltip` `ElemID` *(optional)* - Elem tooltip of the child element. Will be displayed above `tooltip`.
- `enabled` `boolean` *(optional)* - Whether the child element is enabled. Defaults to `true`.
- `game_controller_interaction` `defines.game_controller_interaction` *(optional)* - How the element should interact with game controllers. Defaults to [defines.game_controller_interaction.normal](runtime:defines.game_controller_interaction.normal).
- `ignored_by_interaction` `boolean` *(optional)* - Whether the child element is ignored by interaction. Defaults to `false`.
- `index` `uint` *(optional)* - Location in its parent that the child element should slot into. By default, the child will be appended onto the end.
- `locked` `boolean` *(optional)* - Whether the child element is locked. Defaults to `false`.
- `name` `string` *(optional)* - Name of the child element. It must be unique within the parent element.
- `raise_hover_events` `boolean` *(optional)* - Whether this element will raise [on_gui_hover](runtime:on_gui_hover) and [on_gui_leave](runtime:on_gui_leave). Defaults to `false`.
- `style` `string` *(optional)* - The name of the style prototype to apply to the new element.
- `tags` `Tags` *(optional)* - [Tags](runtime:Tags) associated with the child element.
- `tooltip` `LocalisedString` *(optional)* - Tooltip of the child element.
- `type` `GuiElementType` - The kind of element to add, which potentially has its own attributes as listed below.
- `visible` `boolean` *(optional)* - Whether the child element is visible. Defaults to `true`.

**Returns:**

- `LuaGuiElement` - The GUI element that was added.

### clear

Remove children of this element. Any [LuaGuiElement](runtime:LuaGuiElement) objects referring to the destroyed elements become invalid after this operation.

**Examples:**

```
game.player.gui.top.clear()
```

### destroy

Remove this element, along with its children. Any [LuaGuiElement](runtime:LuaGuiElement) objects referring to the destroyed elements become invalid after this operation.

The top-level GUI elements - [LuaGui::top](runtime:LuaGui::top), [LuaGui::left](runtime:LuaGui::left), [LuaGui::center](runtime:LuaGui::center) and [LuaGui::screen](runtime:LuaGui::screen) - can't be destroyed.

**Examples:**

```
game.player.gui.top.greeting.destroy()
```

### get_mod

The mod that owns this Gui element or `nil` if it's owned by the scenario script.

This has a not-super-expensive, but non-free cost to get.

**Returns:**

- `string` *(optional)*

### get_index_in_parent

Gets the index that this element has in its parent element.

This iterates through the children of the parent of this element, meaning this has a non-free cost to get, but is faster than doing the equivalent in Lua.

**Returns:**

- `uint`

### swap_children

Swaps the children at the given indices in this element.

**Parameters:**

- `index_1` `uint` - The index of the first child.
- `index_2` `uint` - The index of the second child.

### clear_items

Removes the items in this dropdown or listbox.

### get_item

Gets the item at the given index from this dropdown or listbox.

**Parameters:**

- `index` `uint` - The index to get

**Returns:**

- `LocalisedString`

### set_item

Sets the given string at the given index in this dropdown or listbox.

**Parameters:**

- `index` `uint` - The index whose text to replace.
- `string` `LocalisedString` - The text to set at the given index.

### add_item

Inserts a string at the end or at the given index of this dropdown or listbox.

**Parameters:**

- `index` `uint` *(optional)* - The index at which to insert the item.
- `string` `LocalisedString` - The text to insert.

### remove_item

Removes the item at the given index from this dropdown or listbox.

**Parameters:**

- `index` `uint` - The index

### get_slider_minimum

Gets this sliders minimum value.

**Returns:**

- `double`

### get_slider_maximum

Gets this sliders maximum value.

**Returns:**

- `double`

### set_slider_minimum_maximum

Sets this sliders minimum and maximum values. The minimum can't be >= the maximum.

**Parameters:**

- `maximum` `double`
- `minimum` `double`

### get_slider_value_step

Gets the minimum distance this slider can move.

**Returns:**

- `double`

### get_slider_discrete_values

Returns whether this slider only allows discrete values.

**Returns:**

- `boolean`

### set_slider_value_step

Sets the minimum distance this slider can move. The minimum distance can't be > (max - min).

**Parameters:**

- `value` `double`

### set_slider_discrete_values

Sets whether this slider only allows discrete values.

**Parameters:**

- `value` `boolean`

### focus

Focuses this GUI element if possible.

### scroll_to_top

Scrolls this scroll bar to the top.

### scroll_to_bottom

Scrolls this scroll bar to the bottom.

### scroll_to_left

Scrolls this scroll bar to the left.

### scroll_to_right

Scrolls this scroll bar to the right.

### scroll_to_element

Scrolls this scroll bar such that the specified GUI element is visible to the player.

**Parameters:**

- `element` `LuaGuiElement` - The element to scroll to.
- `scroll_mode` `"in-view"` | `"top-third"` *(optional)* - Where the element should be positioned in the scroll-pane. Defaults to `"in-view"`.

### select_all

Selects all the text in this textbox.

### select

Selects a range of text in this textbox.

**Parameters:**

- `end_index` `int` - The index of the last character to select
- `start_index` `int` - The index of the first character to select

**Examples:**

```
-- Select the characters "amp" from "example":
textbox.select(3, 5)
```

```
-- Move the cursor to the start of the text box:
textbox.select(1, 0)
```

### add_tab

Adds the given tab and content widgets to this tabbed pane as a new tab.

**Parameters:**

- `content` `LuaGuiElement` - The content to show when this tab is selected. Can be any type of GUI element.
- `tab` `LuaGuiElement` - The tab to add, must be a GUI element of type "tab".

### remove_tab

Removes the given tab and its associated content from this tabbed pane.

Removing a tab does not destroy the tab or the tab contents. It just removes them from the view.

**Parameters:**

- `tab` `LuaGuiElement` *(optional)* - The tab to remove or `nil` to remove all tabs.

### force_auto_center

Forces this frame to re-auto-center. Only works on frames stored directly in [LuaGui::screen](runtime:LuaGui::screen).

### scroll_to_item

Scrolls the scroll bar such that the specified listbox item is visible to the player.

**Parameters:**

- `index` `int` - The item index to scroll to.
- `scroll_mode` `"in-view"` | `"top-third"` *(optional)* - Where the item should be positioned in the list-box. Defaults to `"in-view"`.

### bring_to_front

Moves this GUI element to the "front" so it will draw over other elements.

Only works for elements in [LuaGui::screen](runtime:LuaGui::screen).

### close_dropdown

Closes the dropdown list if this is a dropdown and it is open.

## Operators

### index

The indexing operator. Gets children by name.

