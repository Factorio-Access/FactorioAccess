# LinkedContainerPrototype

A container that shares its inventory with containers with the same [link_id](runtime:LuaEntity::link_id), which can be set via the GUI. The link IDs are per prototype and force, so only containers with the **same ID**, **same prototype name** and **same force** will share inventories.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `linked-container`

## Properties

### inventory_size

Must be > 0.

**Type:** `ItemStackIndex`

**Required:** Yes

### picture

**Type:** `Sprite`

**Optional:** Yes

### inventory_type

Determines the type of inventory that this linked container has. Whether the inventory has a limiter bar, can be filtered (like cargo wagons), uses a custom stack size for contained item stacks (like artillery wagon), or uses a weight limit (like space age rocket silo).

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

### gui_mode

Players that can access the GUI to change the link ID.

**Type:** `"all"` | `"none"` | `"admins"`

**Optional:** Yes

**Default:** "all"

### circuit_wire_max_distance

The maximum circuit wire distance for this linked container.

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

