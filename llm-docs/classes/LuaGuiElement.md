# LuaGuiElement

An element of a custom GUI. This type is used to represent [any kind](runtime:GuiElementType) of a GUI element - labels, buttons and frames are all instances of this type. Just like [LuaEntity](runtime:LuaEntity), different kinds of elements support different attributes; attempting to access an attribute on an element that doesn't support it (for instance, trying to access the `column_count` of a `textfield`) will result in a runtime error.

For information on all supported GUI elements, see [GuiElementType](runtime:GuiElementType).

Each GUI element allows access to its children by having them as attributes. Thus, one can use the `parent.child` syntax to refer to children. Lua also supports the `parent["child"]` syntax to refer to the same element. This can be used in cases where the child has a name that isn't a valid Lua identifier.

## Methods

### add

Add a new child element to this GuiElement.

**Parameters:**

- `anchor` `GuiAnchor` _(optional)_: Where to position the child element when in the `relative` element.
- `caption` `LocalisedString` _(optional)_: Text displayed on the child element. For frames, this is their title. For other elements, like buttons or labels, this is the content. Whilst this attribute may be used on all elements, it doesn't make sense for tables and flows as they won't display it.
- `elem_tooltip` `ElemID` _(optional)_: Elem tooltip of the child element. Will be displayed above `tooltip`.
- `enabled` `boolean` _(optional)_: Whether the child element is enabled. Defaults to `true`.
- `game_controller_interaction` `defines.game_controller_interaction` _(optional)_: How the element should interact with game controllers. Defaults to [defines.game_controller_interaction.normal](runtime:defines.game_controller_interaction.normal).
- `ignored_by_interaction` `boolean` _(optional)_: Whether the child element is ignored by interaction. Defaults to `false`.
- `index` `uint` _(optional)_: Location in its parent that the child element should slot into. By default, the child will be appended onto the end.
- `name` `string` _(optional)_: Name of the child element. It must be unique within the parent element.
- `raise_hover_events` `boolean` _(optional)_: Whether this element will raise [on_gui_hover](runtime:on_gui_hover) and [on_gui_leave](runtime:on_gui_leave). Defaults to `false`.
- `style` `string` _(optional)_: The name of the style prototype to apply to the new element.
- `tags` `Tags` _(optional)_: [Tags](runtime:Tags) associated with the child element.
- `tooltip` `LocalisedString` _(optional)_: Tooltip of the child element.
- `type` `GuiElementType`: The kind of element to add, which potentially has its own attributes as listed below.
- `visible` `boolean` _(optional)_: Whether the child element is visible. Defaults to `true`.

**Returns:**

- `LuaGuiElement`: The GUI element that was added.

### add_item

Inserts a string at the end or at the given index of this dropdown or listbox.

**Parameters:**

- `index` `uint` _(optional)_: The index at which to insert the item.
- `string` `LocalisedString`: The text to insert.

### add_tab

Adds the given tab and content widgets to this tabbed pane as a new tab.

**Parameters:**

- `content` `LuaGuiElement`: The content to show when this tab is selected. Can be any type of GUI element.
- `tab` `LuaGuiElement`: The tab to add, must be a GUI element of type "tab".

### bring_to_front

Moves this GUI element to the "front" so it will draw over other elements.

Only works for elements in [LuaGui::screen](runtime:LuaGui::screen).

### clear

Remove children of this element. Any [LuaGuiElement](runtime:LuaGuiElement) objects referring to the destroyed elements become invalid after this operation.

### clear_items

Removes the items in this dropdown or listbox.

### close_dropdown

Closes the dropdown list if this is a dropdown and it is open.

### destroy

Remove this element, along with its children. Any [LuaGuiElement](runtime:LuaGuiElement) objects referring to the destroyed elements become invalid after this operation.

The top-level GUI elements - [LuaGui::top](runtime:LuaGui::top), [LuaGui::left](runtime:LuaGui::left), [LuaGui::center](runtime:LuaGui::center) and [LuaGui::screen](runtime:LuaGui::screen) - can't be destroyed.

### focus

Focuses this GUI element if possible.

### force_auto_center

Forces this frame to re-auto-center. Only works on frames stored directly in [LuaGui::screen](runtime:LuaGui::screen).

### get_index_in_parent

Gets the index that this element has in its parent element.

This iterates through the children of the parent of this element, meaning this has a non-free cost to get, but is faster than doing the equivalent in Lua.

**Returns:**

- `uint`: 

### get_item

Gets the item at the given index from this dropdown or listbox.

**Parameters:**

- `index` `uint`: The index to get

**Returns:**

- `LocalisedString`: 

### get_mod

The mod that owns this Gui element or `nil` if it's owned by the scenario script.

This has a not-super-expensive, but non-free cost to get.

**Returns:**

- `string`: 

### get_slider_discrete_values

Returns whether this slider only allows discrete values.

**Returns:**

- `boolean`: 

### get_slider_maximum

Gets this sliders maximum value.

**Returns:**

- `double`: 

### get_slider_minimum

Gets this sliders minimum value.

**Returns:**

- `double`: 

### get_slider_value_step

Gets the minimum distance this slider can move.

**Returns:**

- `double`: 

### remove_item

Removes the item at the given index from this dropdown or listbox.

**Parameters:**

- `index` `uint`: The index

### remove_tab

Removes the given tab and its associated content from this tabbed pane.

Removing a tab does not destroy the tab or the tab contents. It just removes them from the view.

**Parameters:**

- `tab` `LuaGuiElement` _(optional)_: The tab to remove or `nil` to remove all tabs.

### scroll_to_bottom

Scrolls this scroll bar to the bottom.

### scroll_to_element

Scrolls this scroll bar such that the specified GUI element is visible to the player.

**Parameters:**

- `element` `LuaGuiElement`: The element to scroll to.
- `scroll_mode`  _(optional)_: Where the element should be positioned in the scroll-pane. Defaults to `"in-view"`.

### scroll_to_item

Scrolls the scroll bar such that the specified listbox item is visible to the player.

**Parameters:**

- `index` `int`: The item index to scroll to.
- `scroll_mode`  _(optional)_: Where the item should be positioned in the list-box. Defaults to `"in-view"`.

### scroll_to_left

Scrolls this scroll bar to the left.

### scroll_to_right

Scrolls this scroll bar to the right.

### scroll_to_top

Scrolls this scroll bar to the top.

### select

Selects a range of text in this textbox.

**Parameters:**

- `end_index` `int`: The index of the last character to select
- `start_index` `int`: The index of the first character to select

### select_all

Selects all the text in this textbox.

### set_item

Sets the given string at the given index in this dropdown or listbox.

**Parameters:**

- `index` `uint`: The index whose text to replace.
- `string` `LocalisedString`: The text to set at the given index.

### set_slider_discrete_values

Sets whether this slider only allows discrete values.

**Parameters:**

- `value` `boolean`: 

### set_slider_minimum_maximum

Sets this sliders minimum and maximum values. The minimum can't be >= the maximum.

**Parameters:**

- `maximum` `double`: 
- `minimum` `double`: 

### set_slider_value_step

Sets the minimum distance this slider can move. The minimum distance can't be > (max - min).

**Parameters:**

- `value` `double`: 

### swap_children

Swaps the children at the given indices in this element.

**Parameters:**

- `index_1` `uint`: The index of the first child.
- `index_2` `uint`: The index of the second child.

## Attributes

### allow_decimal

**Type:** `boolean`

Whether this textfield (when in numeric mode) allows decimal numbers.

### allow_negative

**Type:** `boolean`

Whether this textfield (when in numeric mode) allows negative numbers.

### allow_none_state

**Type:** `boolean`

Whether the `"none"` state is allowed for this switch.

This can't be set to false if the current switch_state is 'none'.

### anchor

**Type:** `GuiAnchor`

The anchor for this relative widget, if any. Setting `nil` clears the anchor.

### auto_center

**Type:** `boolean`

Whether this frame auto-centers on window resize when stored in [LuaGui::screen](runtime:LuaGui::screen).

### auto_toggle

**Type:** `boolean`

Whether this button will automatically toggle when clicked.

### badge_text

**Type:** `LocalisedString`

The text to display after the normal tab text (designed to work with numbers)

### caption

**Type:** `LocalisedString`

The text displayed on this element. For frames, this is the "heading". For other elements, like buttons or labels, this is the content.

Whilst this attribute may be used on all elements without producing an error, it doesn't make sense for tables and flows as they won't display it.

### children

**Type:** ``LuaGuiElement`[]` _(read-only)_

The child-elements of this GUI element.

### children_names

**Type:** ``string`[]` _(read-only)_

Names of all the children of this element. These are the identifiers that can be used to access the child as an attribute of this element.

### clicked_sprite

**Type:** `SpritePath`

The sprite to display on this sprite-button when it is clicked.

### column_count

**Type:** `uint` _(read-only)_

The number of columns in this table.

### direction

**Type:** `GuiDirection` _(read-only)_

Direction of this element's layout.

### drag_target

**Type:** `LuaGuiElement`

The `frame` that is being moved when dragging this GUI element, if any. This element needs to be a child of the `drag_target` at some level.

Only top-level elements in [LuaGui::screen](runtime:LuaGui::screen) can be `drag_target`s.

### draw_horizontal_line_after_headers

**Type:** `boolean`

Whether this table should draw a horizontal grid line below the first table row.

### draw_horizontal_lines

**Type:** `boolean`

Whether this table should draw horizontal grid lines.

### draw_vertical_lines

**Type:** `boolean`

Whether this table should draw vertical grid lines.

### elem_filters

**Type:** `PrototypeFilter`

The elem filters of this choose-elem-button, if any. The compatible type of filter is determined by `elem_type`.

Writing to this field does not change or clear the currently selected element.

### elem_tooltip

**Type:** `ElemID`

The element tooltip to display when hovering over this element, or `nil`.

### elem_type

**Type:** `ElemType` _(read-only)_

The elem type of this choose-elem-button.

### elem_value

**Type:** 

The elem value of this choose-elem-button, if any.

The `"signal"` type operates with [SignalID](runtime:SignalID).

The `"with-quality"` types operate with [PrototypeWithQuality](runtime:PrototypeWithQuality).

The remaining types use strings.

### enabled

**Type:** `boolean`

Whether this GUI element is enabled. Disabled GUI elements don't trigger events when clicked.

### entity

**Type:** `LuaEntity`

The entity associated with this entity-preview, camera, minimap, if any.

### force

**Type:** `string`

The force this minimap is using, if any.

### game_controller_interaction

**Type:** `defines.game_controller_interaction`

How this element should interact with game controllers.

### gui

**Type:** `LuaGui` _(read-only)_

The GUI this element is a child of.

### horizontal_scroll_policy

**Type:** `ScrollPolicy`

Policy of the horizontal scroll bar.

### hovered_sprite

**Type:** `SpritePath`

The sprite to display on this sprite-button when it is hovered.

### ignored_by_interaction

**Type:** `boolean`

Whether this GUI element is ignored by interaction. This makes clicks on this element 'go through' to the GUI element or even the game surface below it.

### index

**Type:** `uint` _(read-only)_

The index of this GUI element (unique amongst the GUI elements of a LuaPlayer).

### is_password

**Type:** `boolean`

Whether this textfield displays as a password field, which renders all characters as `*`.

### items

**Type:** ``LocalisedString`[]`

The items in this dropdown or listbox.

### left_label_caption

**Type:** `LocalisedString`

The text shown for the left switch label.

### left_label_tooltip

**Type:** `LocalisedString`

The tooltip shown on the left switch label.

### location

**Type:** `GuiLocation`

The location of this widget when stored in [LuaGui::screen](runtime:LuaGui::screen). `nil` if not set or not in [LuaGui::screen](runtime:LuaGui::screen).

### locked

**Type:** `boolean`

Whether this choose-elem-button can be changed by the player.

### lose_focus_on_confirm

**Type:** `boolean`

Whether this textfield loses focus after [defines.events.on_gui_confirmed](runtime:defines.events.on_gui_confirmed) is fired.

### minimap_player_index

**Type:** `uint`

The player index this minimap is using.

### mouse_button_filter

**Type:** `MouseButtonFlags`

The mouse button filters for this button or sprite-button.

### name

**Type:** `string`

The name of this element. `""` if no name was set.

### number

**Type:** `double`

The number to be shown in the bottom right corner of this sprite-button, or `nil` to show nothing.

### numeric

**Type:** `boolean`

Whether this textfield is limited to only numeric characters.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### parent

**Type:** `LuaGuiElement` _(read-only)_

The direct parent of this element. `nil` if this is a top-level element.

### player_index

**Type:** `uint` _(read-only)_

Index into [LuaGameScript::players](runtime:LuaGameScript::players) specifying the player who owns this element.

### position

**Type:** `MapPosition`

The position this camera or minimap is focused on, if any.

### quality

**Type:** `LuaQualityPrototype`

The quality to be shown in the bottom left corner of this sprite-button, or `nil` to show nothing.

### raise_hover_events

**Type:** `boolean`

Whether this element will raise [on_gui_hover](runtime:on_gui_hover) and [on_gui_leave](runtime:on_gui_leave).

### read_only

**Type:** `boolean`

Whether this text-box is read-only. Defaults to `false`.

### resize_to_sprite

**Type:** `boolean`

Whether the sprite widget should resize according to the sprite in it. Defaults to `true`.

### right_label_caption

**Type:** `LocalisedString`

The text shown for the right switch label.

### right_label_tooltip

**Type:** `LocalisedString`

The tooltip shown on the right switch label.

### selectable

**Type:** `boolean`

Whether the contents of this text-box are selectable. Defaults to `true`.

### selected_index

**Type:** `uint`

The selected index for this dropdown or listbox. Returns `0` if none is selected.

### selected_tab_index

**Type:** `uint`

The selected tab index for this tabbed pane, if any.

### show_percent_for_small_numbers

**Type:** `boolean`

Related to the number to be shown in the bottom right corner of this sprite-button. When set to `true`, numbers that are non-zero and smaller than one are shown as a percentage rather than the value. For example, `0.5` will be shown as `50%` instead.

### slider_value

**Type:** `double`

The value of this slider element.

### sprite

**Type:** `SpritePath`

The sprite to display on this sprite-button or sprite in the default state.

### state

**Type:** `boolean`

Is this checkbox or radiobutton checked?

### style

**Type:** 

The style of this element. When read, this evaluates to a [LuaStyle](runtime:LuaStyle). For writing, it only accepts a string that specifies the textual identifier (prototype name) of the desired style.

### surface_index

**Type:** `uint`

The surface index this camera or minimap is using.

### switch_state

**Type:** `SwitchState`

The switch state for this switch.

If [LuaGuiElement::allow_none_state](runtime:LuaGuiElement::allow_none_state) is false this can't be set to `"none"`.

### tabs

**Type:** ``TabAndContent`[]` _(read-only)_

The tabs and contents being shown in this tabbed-pane.

### tags

**Type:** `Tags`

The tags associated with this LuaGuiElement.

### text

**Type:** `string`

The text contained in this textfield or text-box.

### toggled

**Type:** `boolean`

Whether this button is currently toggled. When a button is toggled, it will use the `selected_graphical_set` and `selected_font_color` defined in its style.

### tooltip

**Type:** `LocalisedString`

The text to display when hovering over this element. Writing `""` or `nil` will disable the tooltip.

### type

**Type:** `GuiElementType` _(read-only)_

The type of this GUI element.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### value

**Type:** `double`

How much this progress bar is filled. It is a value in the range `[0, 1]`.

### vertical_centering

**Type:** `boolean`

Whether the content of this table should be vertically centered. Overrides [LuaStyle::column_alignments](runtime:LuaStyle::column_alignments). Defaults to `true`.

### vertical_scroll_policy

**Type:** `ScrollPolicy`

Policy of the vertical scroll bar.

### visible

**Type:** `boolean`

Sets whether this GUI element is visible or completely hidden, taking no space in the layout.

### word_wrap

**Type:** `boolean`

Whether this text-box will word-wrap automatically. Defaults to `false`.

### zoom

**Type:** `double`

The zoom this camera or minimap is using. This value must be positive.

