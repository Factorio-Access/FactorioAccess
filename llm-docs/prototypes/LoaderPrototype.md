# LoaderPrototype

Continuously loads and unloads machines, as an alternative to inserters.

**Parent:** `TransportBeltConnectablePrototype`

## Properties

### Mandatory Properties

#### filter_count

**Type:** `uint8`

How many item filters this loader has. Maximum count of filtered items in loader is 5.

### Optional Properties

#### adjustable_belt_stack_size

**Type:** `boolean`

Loader belt stack size can be adjusted at runtime. Requires [LoaderPrototype::max_belt_stack_size](prototype:LoaderPrototype::max_belt_stack_size) to be > 1.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### allow_container_interaction

**Type:** `boolean`

Whether this loader can load and unload stationary inventories such as containers and crafting machines.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### allow_rail_interaction

**Type:** `boolean`

Whether this loader can load and unload [RollingStockPrototype](prototype:RollingStockPrototype).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### belt_length

**Type:** `double`

How long this loader's belt is. Should be the same as belt_distance, which is hardcoded to `0.5` for [Loader1x2Prototype](prototype:Loader1x2Prototype) and to 0 for [Loader1x1Prototype](prototype:Loader1x1Prototype). See the linked prototypes for an explanation of belt_distance.

**Default:** `{'complex_type': 'literal', 'value': 0.5}`

#### circuit_connector

**Type:** ``CircuitConnectorDefinition`[]`

First the four cardinal directions for `direction_out`, followed by the four directions for `direction_in`.

#### circuit_connector_layer

**Type:** `RenderLayer`

Render layer for all directions of the circuit connectors.

**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### container_distance

**Type:** `double`

The distance between the position of this loader and the tile of the loader's container target.

**Default:** `{'complex_type': 'literal', 'value': 1.5}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### energy_per_item

**Type:** `Energy`

Energy in Joules. Can't be negative.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### energy_source

**Type:** 



#### max_belt_stack_size

**Type:** `uint8`

Loader will not create stacks on belt that are larger than this value. Must be >= 1.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### per_lane_filters

**Type:** `boolean`

If filters are per lane. Can only be set to true if filter_count is equal to 2.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### structure

**Type:** `LoaderStructure`



#### structure_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

