# ContainerPrototype

A generic container, such as a chest. Cannot be rotated.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### inventory_size

**Type:** `ItemStackIndex`

The number of slots in this container.

### Optional Properties

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this container.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_status

**Type:** `EntityStatus`



**Default:** `{'complex_type': 'literal', 'value': 'normal'}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### inventory_type

**Type:** 

Whether the inventory of this container can be filtered (like cargo wagons) or not.

**Default:** `{'complex_type': 'literal', 'value': 'with_bar'}`

#### picture

**Type:** `Sprite`

The picture displayed for this entity.

#### quality_affects_inventory_size

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

