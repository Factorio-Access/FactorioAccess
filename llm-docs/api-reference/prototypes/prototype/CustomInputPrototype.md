# CustomInputPrototype

Used for custom keyboard shortcuts/key bindings in mods. The key associated with the custom input can be changed in the options. This means that `key_sequence` is simply the default key binding.

**Parent:** [Prototype](Prototype.md)
**Type name:** `custom-input`

## Properties

### name

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

For a list of all names used in vanilla, see [data.raw](https://wiki.factorio.com/Data.raw).

It is also the name for the event that is raised when they key (combination) is pressed and action is `"lua"`, see [Tutorial:Script interfaces](https://wiki.factorio.com/Tutorial:Script_interfaces#Custom_input).

**Type:** `string`

**Required:** Yes

**Overrides parent:** Yes

### key_sequence

The default key sequence for this custom input. Use `""` (empty string) for unassigned.

As modifier keys, these names are used: `"CONTROL"`, `"SHIFT"`, `"COMMAND"`, `"ALT"`. Note that `"COMMAND"` is loaded as `"CONTROL"` on Windows and Linux.

`" + "` is used to separate modifier keys from normal keys, like so: `"ALT + G"`. A key binding can contain any amount of individual modifier keys, but only a single normal mouse button or keyboard key (listed below).

**Type:** `string`

**Required:** Yes

### alternative_key_sequence

The alternative key binding for this control. See `key_sequence` for the format.

**Type:** `string`

**Optional:** Yes

### controller_key_sequence

The controller (game pad) keybinding for this control. Use `""` (empty string) for unassigned.

As modifier buttons, these names are used: `"controller-righttrigger"`, `"controller-lefttrigger"`.

`" + "` is used to separate modifier buttons from normal buttons, like so: `"controller-righttrigger + controller-a"`. A key binding can contain any amount of individual modifier buttons, but only a single normal button (listed below).

**Type:** `string`

**Optional:** Yes

### controller_alternative_key_sequence

The alternative controller (game pad) keybinding for this control. See `controller_key_sequence` for the format.

**Type:** `string`

**Optional:** Yes

### linked_game_control

When a custom-input is linked to a game control it won't show up in the control-settings GUI and will fire when the linked control is pressed.

**Type:** `LinkedGameControl`

**Optional:** Yes

**Default:** ""

**Examples:**

```
key_sequence = "",
linked_game_control = "clear-cursor"
```

### consuming

Sets whether internal game events associated with the same key sequence should be fired or blocked. If they are fired ("none"), then the custom input event will happen before the internal game event.

**Type:** `ConsumingType`

**Optional:** Yes

**Default:** "none"

### enabled

If this custom input is enabled. Disabled custom inputs exist but are not used by the game. If disabled, no event is raised when the input is used.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### enabled_while_spectating

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### enabled_while_in_cutscene

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### include_selected_prototype

If true, the type and name of the currently selected prototype will be provided as "selected_prototype" in the raised [Lua event](runtime:CustomInputEvent). [This also works in GUIs](https://forums.factorio.com/96125), not just the game world.

This will also return an item in the cursor such as copper-wire or rail-planner, if nothing is beneath the cursor.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### item_to_spawn

The item will be created when this input is pressed and action is set to "spawn-item". The item must have the [spawnable](prototype:ItemPrototypeFlags::spawnable) flag set.

**Type:** `ItemID`

**Optional:** Yes

### action

A [Lua event](runtime:CustomInputEvent) is only raised if the action is "lua".

**Type:** `"lua"` | `"spawn-item"` | `"toggle-personal-roboport"` | `"toggle-personal-logistic-requests"` | `"toggle-equipment-movement-bonus"`

**Optional:** Yes

**Default:** "lua"

### block_modifiers

If `true`, when the shortcut is activated, the modifiers used for this shortcut can't be re-used to press something else until unpressed. The example where this is useful is ALT+A to activate spidertron remote, where ALT is consumed, so pressing right mouse button before the ALT is unpressed will not trigger pin creation (ALT + right mouse button), but send the selected unit instead.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

