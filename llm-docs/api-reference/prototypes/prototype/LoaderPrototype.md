# LoaderPrototype

Continuously loads and unloads machines, as an alternative to inserters.

**Parent:** [TransportBeltConnectablePrototype](TransportBeltConnectablePrototype.md)
**Abstract:** Yes

## Properties

### structure

**Type:** `LoaderStructure`

**Optional:** Yes

### filter_count

How many item filters this loader has. Maximum count of filtered items in loader is 5.

**Type:** `uint8`

**Required:** Yes

### structure_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### circuit_connector_layer

Render layer for all directions of the circuit connectors.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### container_distance

The distance between the position of this loader and the tile of the loader's container target.

**Type:** `double`

**Optional:** Yes

**Default:** 1.5

### allow_rail_interaction

Whether this loader can load and unload [RollingStockPrototype](prototype:RollingStockPrototype).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_container_interaction

Whether this loader can load and unload stationary inventories such as containers and crafting machines.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### per_lane_filters

If filters are per lane. Can only be set to true if filter_count is equal to 2.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### max_belt_stack_size

Loader will not create stacks on belt that are larger than this value. Must be >= 1.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### adjustable_belt_stack_size

Loader belt stack size can be adjusted at runtime. Requires [LoaderPrototype::max_belt_stack_size](prototype:LoaderPrototype::max_belt_stack_size) to be > 1.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### wait_for_full_stack

When set, this loader will ignore items for which there is not enough to create a full belt stack. Relevant only when loader can create belt stacks.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### respect_insert_limits

When set, this loader will respect the same automated insertion limits as inserters do, instead of inserting up to the full ingredient stack capacity.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### belt_length

How long this loader's belt is. Should be the same as belt_distance, which is hardcoded to `0.5` for [Loader1x2Prototype](prototype:Loader1x2Prototype) and to 0 for [Loader1x1Prototype](prototype:Loader1x1Prototype). See the linked prototypes for an explanation of belt_distance.

**Type:** `double`

**Optional:** Yes

**Default:** 0.5

### energy_source

**Type:** `ElectricEnergySource` | `HeatEnergySource` | `FluidEnergySource` | `VoidEnergySource`

**Optional:** Yes

### energy_per_item

Energy in Joules. Can't be negative.

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

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

First the four cardinal directions for `direction_out`, followed by the four directions for `direction_in`.

**Type:** Array[`CircuitConnectorDefinition`]

**Optional:** Yes

