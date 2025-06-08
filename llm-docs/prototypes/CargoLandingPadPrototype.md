# CargoLandingPadPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### cargo_station_parameters

**Type:** `CargoStationParameters`



#### inventory_size

**Type:** `ItemStackIndex`



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

#### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`



#### radar_range

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### radar_visualisation_color

**Type:** `Color`



#### robot_animation

**Type:** `Animation`

Drawn when a robot brings/takes items from this landing pad.

#### robot_animation_sound

**Type:** `Sound`

Played when a robot brings/takes items from this landing pad. Ignored if `robot_animation` is not defined.

#### robot_landing_location_offset

**Type:** `Vector`

The offset from the center of this landing pad where a robot visually brings/takes items.

#### robot_opened_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### trash_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

