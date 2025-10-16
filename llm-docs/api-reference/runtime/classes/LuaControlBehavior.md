# LuaControlBehavior

The control behavior for an entity. Inserters have logistic network and circuit network behavior logic, lamps have circuit logic and so on. This is an abstract base class that concrete control behaviors inherit.

An control reference becomes invalid once the control behavior is removed or the entity (see [LuaEntity](runtime:LuaEntity)) it resides in is destroyed.

**Abstract:** Yes

## Attributes

### type

The concrete type of this control behavior.

**Read type:** `defines.control_behavior.type`

### entity

The entity this control behavior belongs to.

**Read type:** `LuaEntity`

## Methods

### get_circuit_network

**Parameters:**

- `wire_connector_id` `defines.wire_connector_id` - Wire connector to get circuit network for.

**Returns:**

- `LuaCircuitNetwork` *(optional)* - The circuit network or nil.

