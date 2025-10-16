# LuaDisplayPanelControlBehavior

Control behavior for display panels.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### messages

The full list of configured messages.

**Read type:** Array[`DisplayPanelMessageDefinition`]

**Write type:** Array[`DisplayPanelMessageDefinition`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_message

Get a specific message definition

**Parameters:**

- `index` `uint32` - Message index.

**Returns:**

- `DisplayPanelMessageDefinition` - The message definition at the specified index.

### set_message

Set the message at the specified index

**Parameters:**

- `index` `uint32` - Message index. Use `-1` to append new element.
- `message` `DisplayPanelMessageDefinition` - The message definition for the specified index. Specify `nil` to remove the message.

