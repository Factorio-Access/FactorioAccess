# LuaCircuitNetwork

A circuit network associated with a given entity, connector, and wire type.

## Attributes

### entity

The entity this circuit network reference is associated with.

**Read type:** `LuaEntity`

### wire_type

The wire type this network is associated with.

**Read type:** `defines.wire_type`

### wire_connector_id

Wire connector ID on associated entity this network was gotten from.

**Read type:** `defines.wire_connector_id`

### signals

The circuit network signals last tick. `nil` if there were no signals last tick.

**Read type:** Array[`Signal`]

**Optional:** Yes

### network_id

The circuit networks ID.

**Read type:** `uint32`

### connected_circuit_count

The number of circuits connected to this network.

**Read type:** `uint32`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_signal

**Parameters:**

- `signal` `SignalID` - The signal to read.

**Returns:**

- `int32` - The current value of the signal.

