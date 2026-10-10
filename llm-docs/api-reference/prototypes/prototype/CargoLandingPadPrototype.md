# CargoLandingPadPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `cargo-landing-pad`

## Properties

### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`

**Optional:** Yes

### inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### trash_inventory_size

**Type:** `ItemStackIndex`

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

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

### default_empty_slots_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### cargo_station_parameters

**Type:** `CargoStationParameters`

**Required:** Yes

### robot_door

**Type:** `RobotDoorSpecification`

**Optional:** Yes

### radar_range

In chunks. The radius of how many chunks this cargo landing pad charts around itself.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### radar_visualisation_color

The visualisation used when showing cargo bay unloading distance limits.

**Type:** `Color`

**Optional:** Yes

### radius_visualisation_picture

**Type:** `Sprite`

**Optional:** Yes

