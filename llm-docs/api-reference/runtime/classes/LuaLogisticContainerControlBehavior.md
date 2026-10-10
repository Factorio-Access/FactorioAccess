# LuaLogisticContainerControlBehavior

Control behavior for logistic chests.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### circuit_condition_enabled

Whether the circuit condition is in effect.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_condition

The circuit condition for the logistic container.

**Read type:** `CircuitConditionDefinition`

**Write type:** `CircuitConditionDefinition`

### set_requests

`true` if this logistic container has its requests set by a circuit network.

Can only be set to `true` on containers whose [logistic_mode](runtime:LuaEntityPrototype::logistic_mode) or [override_logistic_mode](runtime:LuaEntity::override_logistic_mode) is set to `"requester"` or `"buffer"`.

**Read type:** `boolean`

**Write type:** `boolean`

### read_contents

`true` if this logistic container is sending its content to a circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_empty_slots

**Read type:** `boolean`

**Write type:** `boolean`

### empty_slots_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

