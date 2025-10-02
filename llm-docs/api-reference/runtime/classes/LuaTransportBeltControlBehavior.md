# LuaTransportBeltControlBehavior

Control behavior for transport belts.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### read_contents

If the belt will read the contents and send them to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_contents_mode

The read mode for the belt.

**Read type:** `defines.control_behavior.transport_belt.content_read_mode`

**Write type:** `defines.control_behavior.transport_belt.content_read_mode`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

