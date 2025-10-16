# LuaInserterControlBehavior

Control behavior for inserters.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### circuit_set_filters

`true` if filters are set from circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_read_hand_contents

`true` if the contents of the inserter hand should be sent to the circuit network

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_hand_read_mode

The hand read mode for the inserter.

**Read type:** `defines.control_behavior.inserter.hand_read_mode`

**Write type:** `defines.control_behavior.inserter.hand_read_mode`

### circuit_set_stack_size

If the stack size of the inserter is set through the circuit network or not.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_stack_control_signal

The signal used to set the stack size of the inserter.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

