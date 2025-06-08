# LuaWireConnector

A wire connector of a given entity. Allows to find wires, add or remove wires and do some basic operations specific to those connectors.

## Methods

### can_wire_reach

Checks if a wire can reach from this connector to the other connector.

**Parameters:**

- `other_connector` : Target to which a wire reach is to be checked.

**Returns:**

- `boolean`: 

### connect_to

Connects this connector to other wire connector.

**Parameters:**

- `origin` `defines.wire_origin` _(optional)_: Origin of the wire. Defaults to `defines.wire_origin.player`.
- `reach_check` `boolean` _(optional)_: True by default. For wires out of reach or on different surfaces, `false` must be provided.
- `target` `LuaWireConnector`: Other connector to which a wire should be added.

**Returns:**

- `boolean`: Whether a connection was made.

### disconnect_all

Removes all wires going out of this wire connector.

**Parameters:**

- `origin` `defines.wire_origin` _(optional)_: Origin of the wires to remove. Defaults to `defines.wire_origin.player`.

**Returns:**

- `boolean`: True if any wire was removed.

### disconnect_from

Disconnects this connector from other wire connector.

**Parameters:**

- `origin` `defines.wire_origin` _(optional)_: Origin of the wire. Defaults to `defines.wire_origin.player`.
- `target` `LuaWireConnector`: Other connector to which wire to be removed should be removed.

**Returns:**

- `boolean`: Whether a connection was removed.

### have_common_neighbour

Checks if this and other wire connector have a common neighbour.

**Parameters:**

- `ignore_ghost_neighbours` `boolean` _(optional)_: 
- `other_connector` `LuaWireConnector`: Other connector to check for common neighbour.

**Returns:**

- `boolean`: 

### is_connected_to

Checks if this connector has any wire going to the other connector.

**Parameters:**

- `origin` `defines.wire_origin` _(optional)_: Origin of the wire. Defaults to `defines.wire_origin.player`.
- `target` `LuaWireConnector`: Other connector to check for a connection to.

**Returns:**

- `boolean`: 

## Attributes

### connection_count

**Type:** `uint` _(read-only)_

Amount of wires going out of this connector. It includes all wires (ghost wires and real wires).

### connections

**Type:** ``WireConnection`[]` _(read-only)_

All wire connectors this connector is connected to.

### is_ghost

**Type:** `boolean` _(read-only)_

If this connector is owned by an entity inside of a ghost. If any of 2 ends of a wire attaches to a ghost connector, then a wire is considered to be a ghost.

### network_id

**Type:** `uint` _(read-only)_

Index of a CircuitNetwork or ElectricSubNetwork which is going through this wire connector. Returns 0 if there is no network associated with this wire connector right now. CircuitNetwork indexes are independent of indexes of ElectricSubNetwork so they may collide with each other.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:** `LuaEntity` _(read-only)_

The entity this wire connector belongs to. May return entity ghost instead if this wire connector belongs to inner entity.

### real_connection_count

**Type:** `uint` _(read-only)_

Amount of real wires going out of this connector. It only includes wires for which both wire connectors are real.

### real_connections

**Type:** ``WireConnection`[]` _(read-only)_

All wire connectors this connector is connected to with real wires.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### wire_connector_id

**Type:** `defines.wire_connector_id` _(read-only)_

Identifier of this connector in the entity this connector belongs to.

### wire_type

**Type:** `defines.wire_type` _(read-only)_

The type of wires that can be connected to this connector.

