# ContainerPrototype

A generic container, such as a chest. Cannot be rotated.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `container`

## Properties

### inventory_size

The number of slots in this container.

**Type:** `ItemStackIndex`

**Required:** Yes

### quality_affects_inventory_size

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### picture

The picture displayed for this entity.

**Type:** `Sprite`

**Optional:** Yes

### inventory_type

Determines the type of inventory that this container has. Whether the inventory has a limiter bar, can be filtered (like cargo wagons), uses a custom stack size for contained item stacks (like artillery wagon), or uses a weight limit (like space age rocket silo).

**Type:** `"normal"` | `"with_bar"` | `"with_filters_and_bar"` | `"with_custom_stack_size"` | `"with_weight_limit"`

**Optional:** Yes

**Default:** "with_bar"

### inventory_properties

Only used when `inventory_type` is `"with_custom_stack_size"`.

**Type:** `InventoryWithCustomStackSizeSpecification`

**Optional:** Yes

### inventory_weight_limit

Only used when `inventory_type` is `"with_weight_limit"`.

**Type:** `Weight`

**Optional:** Yes

**Default:** 0

### circuit_wire_max_distance

The maximum circuit wire distance for this container.

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

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

### default_status

**Type:** `EntityStatus`

**Optional:** Yes

**Default:** "normal"

