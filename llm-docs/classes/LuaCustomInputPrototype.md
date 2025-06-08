# LuaCustomInputPrototype

Prototype of a custom input.

**Parent:** `LuaPrototypeBase`

## Attributes

### action

**Type:** `string` _(read-only)_

The action that happens when this custom input is triggered.

### alternative_key_sequence

**Type:** `string` _(read-only)_

The default alternative key sequence for this custom input, if any

### consuming

**Type:**  _(read-only)_

The consuming type.

### controller_alternative_key_sequence

**Type:** `string` _(read-only)_

The default controller alternative key sequence for this custom input, if any

### controller_key_sequence

**Type:** `string` _(read-only)_

The default controller key sequence for this custom input, if any

### enabled

**Type:** `boolean` _(read-only)_

Whether this custom input is enabled. Disabled custom inputs exist but are not used by the game.

### enabled_while_in_cutscene

**Type:** `boolean` _(read-only)_

Whether this custom input is enabled while using the cutscene controller.

### enabled_while_spectating

**Type:** `boolean` _(read-only)_

Whether this custom input is enabled while using the spectator controller.

### event_id

**Type:** `defines.events` _(read-only)_

Event identifier associated with this custom input.

### include_selected_prototype

**Type:** `boolean` _(read-only)_

Whether this custom input will include the selected prototype (if any) when triggered.

### item_to_spawn

**Type:** `LuaItemPrototype` _(read-only)_

The item that gets spawned when this custom input is fired, if any.

### key_sequence

**Type:** `string` _(read-only)_

The default key sequence for this custom input.

### linked_game_control

**Type:** `LinkedGameControl` _(read-only)_

The linked game control name, if any.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

