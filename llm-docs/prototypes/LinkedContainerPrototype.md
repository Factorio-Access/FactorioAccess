# LinkedContainerPrototype

A container that shares its inventory with containers with the same [link_id](runtime:LuaEntity::link_id), which can be set via the GUI. The link IDs are per prototype and force, so only containers with the **same ID**, **same prototype name** and **same force** will share inventories.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### inventory_size

**Type:** `ItemStackIndex`

Must be > 0.

### Optional Properties

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this linked container.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### gui_mode

**Type:** 

Players that can access the GUI to change the link ID.

**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### inventory_type

**Type:** 

Whether the inventory of this container can be filtered (like cargo wagons) or not.

**Default:** `{'complex_type': 'literal', 'value': 'with_bar'}`

#### picture

**Type:** `Sprite`



