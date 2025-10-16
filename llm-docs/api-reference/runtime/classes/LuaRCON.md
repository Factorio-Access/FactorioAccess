# LuaRCON

An interface to send messages to the calling RCON interface through the global object named `rcon`.

## Attributes

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### print

Print text to the calling RCON interface if any.

**Parameters:**

- `message` `LocalisedString`

