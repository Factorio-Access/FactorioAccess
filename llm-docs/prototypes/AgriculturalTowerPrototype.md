# AgriculturalTowerPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### crane

**Type:** `AgriculturalCraneProperties`



#### crane_energy_usage

**Type:** `Energy`

The amount of energy this agricultural tower uses while the crane is moving.

#### energy_source

**Type:** `EnergySource`



#### energy_usage

**Type:** `Energy`

The amount of energy this agricultural tower uses for each planted or harvested [plant](prototype:PlantPrototype).

#### input_inventory_size

**Type:** `ItemStackIndex`



#### radius

**Type:** `double`

The radius represents [grid tiles](prototype:AgriculturalTowerPrototype::growth_grid_tile_size) which are created around the agricultural tower from its [collision box](prototype:EntityPrototype::collision_box).

Must be positive.

### Optional Properties

#### accepted_seeds

**Type:** ``ItemID`[]`

When missing, all items with [plant result](prototype:ItemPrototype::plant_result) will be accepted. When provided, only items on this list that have plant result will be accepted.

#### arm_extending_sound

**Type:** `InterruptibleSound`



#### arm_extending_sound_source

**Type:** `string`



#### central_orienting_sound

**Type:** `InterruptibleSound`



#### central_orienting_sound_source

**Type:** `string`



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

**Type:** `CraftingMachineGraphicsSet`



#### grappler_extending_sound

**Type:** `InterruptibleSound`



#### grappler_extending_sound_source

**Type:** `string`



#### grappler_orienting_sound

**Type:** `InterruptibleSound`



#### grappler_orienting_sound_source

**Type:** `string`



#### growth_area_radius

**Type:** `double`

The minimum radius of empty space a [plant](prototype:PlantPrototype) requires around it to be planted.

Must be >= 0 and <= growth_grid_tile_size / 2

**Default:** `{'complex_type': 'literal', 'value': 0.95}`

#### growth_grid_tile_size

**Type:** `uint32`

The size of one grid tile a [plant](prototype:PlantPrototype) is planted into.

Must be positive.

**Default:** `{'complex_type': 'literal', 'value': 3}`

#### harvesting_procedure_points

**Type:** ``Vector3D`[]`



#### harvesting_sound

**Type:** `Sound`



#### output_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### planting_procedure_points

**Type:** ``Vector3D`[]`



#### planting_sound

**Type:** `Sound`



#### radius_visualisation_picture

**Type:** `Sprite`



#### random_growth_offset

**Type:** `double`

The maximum offset from the grid tile center which will be applied to the planting spot selected by this agricultural tower.

Must be >= 0 and < 1.

**Default:** `{'complex_type': 'literal', 'value': 0.25}`

#### randomize_planting_tile

**Type:** `boolean`

Whether the agricultural tower will start from a random grid tile when given a planting task.

**Default:** `{'complex_type': 'literal', 'value': True}`

