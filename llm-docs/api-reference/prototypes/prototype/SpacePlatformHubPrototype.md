# SpacePlatformHubPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `space-platform-hub`
**Visibility:** space_age

## Properties

### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`

**Optional:** Yes

### inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### persistent_ambient_sounds

**Type:** `PersistentWorldAmbientSoundsDefinition`

**Optional:** Yes

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

### default_speed_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_damage_taken_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_empty_slots_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### platform_repair_speed_modifier

Repair speed of entities is multiplied by this value when they are on a space platform with this hub prototype.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### weight

Mass which this entity adds to total space platform mass when placed.

**Type:** `Weight`

**Optional:** Yes

**Default:** 0

### cargo_station_parameters

**Type:** `CargoStationParameters`

**Required:** Yes

### build_grid_size

Has to be 256 to make blueprints snap to (0, 0) most of the time.

**Type:** `256`

**Optional:** Yes

**Default:** 256

**Overrides parent:** Yes

