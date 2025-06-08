# LuaGenericOnOffControlBehavior

An abstract base class for behaviors that support switching the entity on or off based on some condition.

**Parent:** `LuaControlBehavior`

## Attributes

### circuit_condition

**Type:** `CircuitConditionDefinition`

The circuit condition. Writing `nil` clears the circuit condition.

### circuit_enable_disable

**Type:** `boolean`

`true` if this entity enable/disable state is controlled by circuit condition

### connect_to_logistic_network

**Type:** `boolean`

`true` if this should connect to the logistic network.

### disabled

**Type:** `boolean` _(read-only)_

If the entity is currently disabled because of the control behavior.

### logistic_condition

**Type:** `CircuitConditionDefinition`

The logistic condition. Writing `nil` clears the logistic condition.

