# LuaCircuitNetwork

A circuit network associated with a given entity, connector, and wire type.

## Methods

### get_signal



**Parameters:**

- `signal` `SignalID`: The signal to read.

**Returns:**

- `int`: The current value of the signal.

## Attributes

### connected_circuit_count

**Type:** `uint` _(read-only)_

The number of circuits connected to this network.

### entity

**Type:** `LuaEntity` _(read-only)_

The entity this circuit network reference is associated with.

### network_id

**Type:** `uint` _(read-only)_

The circuit networks ID.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### signals

**Type:** ``Signal`[]` _(read-only)_

The circuit network signals last tick. `nil` if there were no signals last tick.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### wire_connector_id

**Type:** `defines.wire_connector_id` _(read-only)_

Wire connector ID on associated entity this network was gotten from.

### wire_type

**Type:** `defines.wire_type` _(read-only)_

The wire type this network is associated with.

