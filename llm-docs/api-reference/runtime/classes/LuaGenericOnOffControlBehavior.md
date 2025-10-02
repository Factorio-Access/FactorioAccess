# LuaGenericOnOffControlBehavior

An abstract base class for behaviors that support switching the entity on or off based on some condition.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

**Abstract:** Yes

## Attributes

### disabled

If the entity is currently disabled because of the control behavior.

**Read type:** `boolean`

### circuit_enable_disable

`true` if this entity enable/disable state is controlled by circuit condition

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_condition

The circuit condition. Writing `nil` clears the circuit condition.

**Read type:** `CircuitConditionDefinition`

**Write type:** `CircuitConditionDefinition`

### connect_to_logistic_network

`true` if this should connect to the logistic network.

**Read type:** `boolean`

**Write type:** `boolean`

### logistic_condition

The logistic condition. Writing `nil` clears the logistic condition.

**Read type:** `CircuitConditionDefinition`

**Write type:** `CircuitConditionDefinition`

