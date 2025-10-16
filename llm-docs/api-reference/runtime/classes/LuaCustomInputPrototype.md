# LuaCustomInputPrototype

Prototype of a custom input.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### event_id

Event identifier associated with this custom input.

**Read type:** `defines.events`

### key_sequence

The default key sequence for this custom input.

**Read type:** `string`

### alternative_key_sequence

The default alternative key sequence for this custom input, if any

**Read type:** `string`

**Optional:** Yes

### controller_key_sequence

The default controller key sequence for this custom input, if any

**Read type:** `string`

**Optional:** Yes

### controller_alternative_key_sequence

The default controller alternative key sequence for this custom input, if any

**Read type:** `string`

**Optional:** Yes

### linked_game_control

The linked game control name, if any.

**Read type:** `LinkedGameControl`

**Optional:** Yes

### consuming

The consuming type.

**Read type:** `"none"` | `"game-only"`

### action

The action that happens when this custom input is triggered.

**Read type:** `string`

### enabled

Whether this custom input is enabled. Disabled custom inputs exist but are not used by the game.

**Read type:** `boolean`

### enabled_while_spectating

Whether this custom input is enabled while using the spectator controller.

**Read type:** `boolean`

### enabled_while_in_cutscene

Whether this custom input is enabled while using the cutscene controller.

**Read type:** `boolean`

### include_selected_prototype

Whether this custom input will include the selected prototype (if any) when triggered.

**Read type:** `boolean`

### item_to_spawn

The item that gets spawned when this custom input is fired, if any.

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

