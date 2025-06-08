# ProxyContainerPrototype

A container that must be set to point at other entity and inventory index so it can forward all inventory interactions to the other entity.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Optional Properties

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_inventory_content

**Type:** `boolean`

If the content of the inventory should be rendered in alt mode.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### picture

**Type:** `Sprite`



