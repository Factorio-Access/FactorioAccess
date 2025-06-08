# LuaInserterControlBehavior

Control behavior for inserters.

**Parent:** `LuaGenericOnOffControlBehavior`

## Attributes

### circuit_hand_read_mode

**Type:** `defines.control_behavior.inserter.hand_read_mode`

The hand read mode for the inserter.

### circuit_read_hand_contents

**Type:** `boolean`

`true` if the contents of the inserter hand should be sent to the circuit network

### circuit_set_filters

**Type:** `boolean`

`true` if filters are set from circuit network

### circuit_set_stack_size

**Type:** `boolean`

If the stack size of the inserter is set through the circuit network or not.

### circuit_stack_control_signal

**Type:** `SignalID`

The signal used to set the stack size of the inserter.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

