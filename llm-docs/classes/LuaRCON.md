# LuaRCON

An interface to send messages to the calling RCON interface through the global object named `rcon`.

## Methods

### print

Print text to the calling RCON interface if any.

**Parameters:**

- `message` `LocalisedString`: 

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

