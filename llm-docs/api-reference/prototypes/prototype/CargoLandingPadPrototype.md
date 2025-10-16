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

### cargo_station_parameters

**Type:** `CargoStationParameters`

**Required:** Yes

### robot_animation

Drawn when a robot brings/takes items from this landing pad.

**Type:** `Animation`

**Optional:** Yes

### robot_landing_location_offset

The offset from the center of this landing pad where a robot visually brings/takes items.

**Type:** `Vector`

**Optional:** Yes

### robot_opened_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### robot_animation_sound

Played when a robot brings/takes items from this landing pad. Only loaded if `robot_animation` is defined.

**Type:** `Sound`

**Optional:** Yes

### radar_range

In chunks. The radius of how many chunks this cargo landing pad charts around itself.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### radar_visualisation_color

**Type:** `Color`

**Optional:** Yes

