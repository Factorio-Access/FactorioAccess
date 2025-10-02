# CustomInputEvent

Called when a [CustomInputPrototype](prototype:CustomInputPrototype) is activated.

## Event Data

### cursor_direction

**Type:** `defines.direction` *(optional)*

Cursor direction.

### cursor_display_location

**Type:** `GuiLocation`

The mouse cursor display location when the custom input was activated.

### cursor_position

**Type:** `MapPosition`

The mouse cursor position when the custom input was activated.

### element

**Type:** `LuaGuiElement` *(optional)*

The GUI element under the cursor when the custom input was activated.

### input_name

**Type:** `string`

The prototype name of the custom input that was activated.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player that activated the custom input.

### selected_prototype

**Type:** `SelectedPrototypeData` *(optional)*

Information about the prototype that is selected when the custom input is used. Needs to be enabled on the custom input's prototype. `nil` if none is selected.

### tick

**Type:** `uint`

Tick the event was generated.

