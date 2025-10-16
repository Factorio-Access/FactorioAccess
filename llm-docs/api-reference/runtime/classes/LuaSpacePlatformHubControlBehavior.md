# LuaSpacePlatformHubControlBehavior

Control behavior for space platform hubs

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### read_contents

`true` if this hub is sending its content to a circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### send_to_platform

Whether the signals are used for circuit conditions in the platform's schedule

**Read type:** `boolean`

**Write type:** `boolean`

### read_moving_from

Whether current connection "from" end is sent to circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_moving_to

Whether current connection "to" end is sent to circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_speed

Whether current speed of space platform is sent to circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### speed_signal

Signal to be transmitted with platform's current speed.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### read_damage_taken

Whether damage taken by the space platform is sent to circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### damage_taken_signal

Signal to be transmitted with platform's damage taken value.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

