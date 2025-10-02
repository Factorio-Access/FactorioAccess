# QualityPrototype

One quality step. Its effects are specified by the level and the various multiplier and bonus properties. Properties ending in `_multiplier` are applied multiplicatively to their base property, properties ending in `_bonus` are applied additively.

**Parent:** [Prototype](Prototype.md)
**Type name:** `quality`
**Instance limit:** 255

## Properties

### draw_sprite_by_default

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### color

**Type:** `Color`

**Required:** Yes

### level

Requires Space Age to use level greater than `0`.

**Type:** `uint32`

**Required:** Yes

### next

**Type:** `QualityID`

**Optional:** Yes

### next_probability

The quality [effect of the module](prototype:ModulePrototype::effect) is multiplied by this. For example, if a module's quality effect is 0.2 and the current quality's next_probability is 0.1, then the chance to get the next quality item is 2%.

Must be in range [0, 1.0].

**Type:** `double`

**Optional:** Yes

**Default:** 0

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### beacon_power_usage_multiplier

Must be >= 0.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### mining_drill_resource_drain_multiplier

Must be in range `[0, 1]`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### science_pack_drain_multiplier

Must be in range `[0, 1]`.

Only affects labs with [LabPrototype::uses_quality_drain_modifier](prototype:LabPrototype::uses_quality_drain_modifier) set.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### name

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

Requires Space Age to create prototypes with name other than `normal` or `quality-unknown`.

**Type:** `string`

**Required:** Yes

**Overrides parent:** Yes

### default_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + 0.3 * `level`"

### inserter_speed_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### fluid_wagon_capacity_multiplier

Must be >= 0.01.

Only affects fluid wagons with [FluidWagonPrototype::quality_affects_capacity](prototype:FluidWagonPrototype::quality_affects_capacity) set.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### inventory_size_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### lab_research_speed_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### crafting_machine_speed_multiplier

Must be >= 0.01.

Will be ignored by crafting machines with [CraftingMachinePrototype::crafting_speed_quality_multiplier](prototype:CraftingMachinePrototype::crafting_speed_quality_multiplier) set.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### crafting_machine_energy_usage_multiplier

Must be >= 0.01.

Only affects crafting machines with [CraftingMachinePrototype::quality_affects_energy_usage](prototype:CraftingMachinePrototype::quality_affects_energy_usage) set.

Will be ignored by crafting machines with [CraftingMachinePrototype::energy_usage_quality_multiplier](prototype:CraftingMachinePrototype::energy_usage_quality_multiplier) set.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### logistic_cell_charging_energy_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### tool_durability_multiplier

Must be >= 0.01.

Affects the durability of [tool items](prototype:ToolPrototype) like science packs, repair tools and armor.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + `level`"

### accumulator_capacity_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + `level`"

### flying_robot_max_energy_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + `level`"

### range_multiplier

Must be within `[1, 3]`.

Affects the range of [attack parameters](prototype:AttackParameters), e.g. those used by combat robots, units, guns and turrets.

**Type:** `double`

**Optional:** Yes

**Default:** "min(1 + 0.1 * `level`, 3)"

### asteroid_collector_collection_radius_bonus

Must be >= 0.

Performance warning: the navigation has to pre-calculate ranges for the highest tier collector possible, so you should keep this collection radius within reasonable values.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `level`"

### equipment_grid_width_bonus

**Type:** `int16`

**Optional:** Yes

**Default:** "Value of `level`"

### equipment_grid_height_bonus

**Type:** `int16`

**Optional:** Yes

**Default:** "Value of `level`"

### electric_pole_wire_reach_bonus

Must be >= 0.

**Type:** `float`

**Optional:** Yes

**Default:** "2 * `level`"

### electric_pole_supply_area_distance_bonus

Must be >= 0.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `level`"

### beacon_supply_area_distance_bonus

Only affects beacons with [BeaconPrototype::quality_affects_supply_area](prototype:BeaconPrototype::quality_affects_supply_area) set.

Must be >= 0 and <= 64.

**Type:** `float`

**Optional:** Yes

**Default:** "clamp(`level`, 0, 64)"

### mining_drill_mining_radius_bonus

Only affects mining drills with [MiningDrillPrototype::quality_affects_mining_radius](prototype:MiningDrillPrototype::quality_affects_mining_radius) set.

Must be >= 0.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `level`"

### logistic_cell_charging_station_count_bonus

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `level`"

### beacon_module_slots_bonus

Only affects beacons with [BeaconPrototype::quality_affects_module_slots](prototype:BeaconPrototype::quality_affects_module_slots) set.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** "Value of `level`"

### crafting_machine_module_slots_bonus

Only affects crafting machines with [CraftingMachinePrototype::quality_affects_module_slots](prototype:CraftingMachinePrototype::quality_affects_module_slots) set.

Will be ignored by crafting machines with [CraftingMachinePrototype::module_slots_quality_bonus](prototype:CraftingMachinePrototype::module_slots_quality_bonus) set.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** "Value of `level`"

### mining_drill_module_slots_bonus

Only affects mining drills with [MiningDrillPrototype::quality_affects_module_slots](prototype:MiningDrillPrototype::quality_affects_module_slots) set.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** "Value of `level`"

### lab_module_slots_bonus

Only affects labs with [LabPrototype::quality_affects_module_slots](prototype:LabPrototype::quality_affects_module_slots) set.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** "Value of `level`"

