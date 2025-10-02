# AgriculturalTowerPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `agricultural-tower`
**Visibility:** space_age

## Properties

### graphics_set

**Type:** `CraftingMachineGraphicsSet`

**Optional:** Yes

### crane

**Type:** `AgriculturalCraneProperties`

**Required:** Yes

### energy_source

**Type:** `EnergySource`

**Required:** Yes

### input_inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### output_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### energy_usage

The amount of energy this agricultural tower uses for each planted or harvested [plant](prototype:PlantPrototype).

**Type:** `Energy`

**Required:** Yes

### crane_energy_usage

The amount of energy this agricultural tower uses while the crane is moving.

**Type:** `Energy`

**Required:** Yes

### radius

The radius represents [grid tiles](prototype:AgriculturalTowerPrototype::growth_grid_tile_size) which are created around the agricultural tower from its [collision box](prototype:EntityPrototype::collision_box).

Must be positive.

**Type:** `double`

**Required:** Yes

### growth_grid_tile_size

The size of one grid tile a [plant](prototype:PlantPrototype) is planted into.

Must be positive.

**Type:** `uint32`

**Optional:** Yes

**Default:** 3

### growth_area_radius

The minimum radius of empty space a [plant](prototype:PlantPrototype) requires around it to be planted.

Must be >= 0 and <= growth_grid_tile_size / 2

**Type:** `double`

**Optional:** Yes

**Default:** 0.95

### random_growth_offset

The maximum offset from the grid tile center which will be applied to the planting spot selected by this agricultural tower.

Must be >= 0 and < 1.

**Type:** `double`

**Optional:** Yes

**Default:** 0.25

### randomize_planting_tile

Whether the agricultural tower will start from a random grid tile when given a planting task.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### radius_visualisation_picture

**Type:** `Sprite`

**Optional:** Yes

### central_orienting_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### arm_extending_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### grappler_orienting_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### grappler_extending_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### planting_sound

**Type:** `Sound`

**Optional:** Yes

### harvesting_sound

**Type:** `Sound`

**Optional:** Yes

### central_orienting_sound_source

**Type:** `string`

**Optional:** Yes

### arm_extending_sound_source

**Type:** `string`

**Optional:** Yes

### grappler_orienting_sound_source

**Type:** `string`

**Optional:** Yes

### grappler_extending_sound_source

**Type:** `string`

**Optional:** Yes

### planting_procedure_points

**Type:** Array[`Vector3D`]

**Optional:** Yes

### harvesting_procedure_points

**Type:** Array[`Vector3D`]

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

### accepted_seeds

When missing, all items with [plant result](prototype:ItemPrototype::plant_result) will be accepted. When provided, only items on this list that have plant result will be accepted.

**Type:** Array[`ItemID`]

**Optional:** Yes

