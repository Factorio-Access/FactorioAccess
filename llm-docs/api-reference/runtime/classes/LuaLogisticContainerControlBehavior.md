# LuaLogisticContainerControlBehavior

Control behavior for logistic chests.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### circuit_exclusive_mode_of_operation

The circuit mode of operations for the logistic container. Can only be set on containers whose [logistic_mode](runtime:LuaEntityPrototype::logistic_mode) is set to `"requester"` or `"buffer"`.

**Read type:** `defines.control_behavior.logistic_container.exclusive_mode`

**Write type:** `defines.control_behavior.logistic_container.exclusive_mode`

### circuit_condition_enabled

Whether the circuit condition is in effect

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_condition

The circuit condition for the logistic container.

**Read type:** `CircuitConditionDefinition`

**Write type:** `CircuitConditionDefinition`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

