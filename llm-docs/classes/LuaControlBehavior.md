# LuaControlBehavior

The control behavior for an entity. Inserters have logistic network and circuit network behavior logic, lamps have circuit logic and so on. This is an abstract base class that concrete control behaviors inherit.

An control reference becomes invalid once the control behavior is removed or the entity (see [LuaEntity](runtime:LuaEntity)) it resides in is destroyed.

## Methods

### get_circuit_network



**Parameters:**

- `wire_connector_id` `defines.wire_connector_id`: Wire connector to get circuit network for.

**Returns:**

- `LuaCircuitNetwork`: The circuit network or nil.

## Attributes

### entity

**Type:** `LuaEntity` _(read-only)_

The entity this control behavior belongs to.

### type

**Type:** `defines.control_behavior.type` _(read-only)_

The concrete type of this control behavior.

