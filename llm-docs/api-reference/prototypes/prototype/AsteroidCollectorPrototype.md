# AsteroidCollectorPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `asteroid-collector`
**Visibility:** space_age

## Properties

### arm_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 5

### arm_inventory_size_quality_increase

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 39

### inventory_size_quality_increase

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 5

### graphics_set

**Type:** `AsteroidCollectorGraphicsSet`

**Required:** Yes

### passive_energy_usage

**Type:** `Energy`

**Required:** Yes

### arm_energy_usage

**Type:** `Energy`

**Required:** Yes

### arm_slow_energy_usage

If `arm_energy_usage` is not met, attempts to move slower at the cost of `arm_slow_energy_usage`.

**Type:** `Energy`

**Required:** Yes

### energy_usage_quality_scaling

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### arm_count_base

**Type:** `uint32`

**Optional:** Yes

**Default:** 3

### arm_count_quality_scaling

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### head_collection_radius

**Type:** `float`

**Optional:** Yes

**Default:** 0.6

### collection_box_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### deposit_radius

**Type:** `float`

**Optional:** Yes

**Default:** 1.5

### arm_speed_base

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### arm_speed_quality_scaling

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### arm_angular_speed_cap_base

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### arm_angular_speed_cap_quality_scaling

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### tether_size

**Type:** `float`

**Optional:** Yes

**Default:** 0.4

### unpowered_arm_speed_scale

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### minimal_arm_swing_segment_retraction

**Type:** `uint32`

**Optional:** Yes

**Default:** 6

### held_items_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### held_items_spread

**Type:** `float`

**Optional:** Yes

**Default:** 0.15

### held_items_display_count

**Type:** `uint8`

**Optional:** Yes

**Default:** 5

### munch_sound

**Type:** `Sound`

**Optional:** Yes

### deposit_sound

**Type:** `Sound`

**Optional:** Yes

### arm_extend_sound

**Type:** `Sound`

**Optional:** Yes

### arm_retract_sound

**Type:** `Sound`

**Optional:** Yes

### energy_source

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

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

### radius_visualisation_picture

**Type:** `Sprite`

**Optional:** Yes

### collection_radius

Must be positive.

**Type:** `double`

**Required:** Yes

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### arm_color_gradient

**Type:** Array[`Color`]

**Optional:** Yes

**Default:** "{{1, 1, 1}}"

