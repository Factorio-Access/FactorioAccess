# ProxyContainerPrototype

A container that must be set to point at other entity and inventory index so it can forward all inventory interactions to the other entity.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `proxy-container`

## Properties

### direction_count

Amount of directions this container should have. Allowed values are 1, 2 and 4.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### picture

**Type:** `Sprite4Way`

**Optional:** Yes

### draw_inventory_content

If the content of the inventory should be rendered in alt mode.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_connector

If given, there must be exactly `direction_count` elements in the table.

**Type:** Array[`CircuitConnectorDefinition`]

**Optional:** Yes

### default_empty_slots_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

