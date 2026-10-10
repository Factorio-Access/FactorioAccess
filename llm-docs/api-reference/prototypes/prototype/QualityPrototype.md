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

Probability that a crafting machine affected by a 100% quality [effect from modules](prototype:ModulePrototype::effect) will cause quality to be increased.

Probability is scaled linearly with quality effect. E.g. for `next_probability = 1`, 100% quality effect means quality is always increased, at 50% quality effect the quality is increased 50% of the time and so on.

Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### chain_probability

Probability of additional quality increase happening after quality was increased to reach this quality in the same crafting/mining operation.

Must be in range `[0, 1]`.

**Type:** `double`

**Optional:** Yes

**Default:** "clamp(`next_probability * 0.1, 0, 1)`"

### previous_probability

Probability that a crafting machine affected by a -100% quality [effect from modules](prototype:ModulePrototype::effect) will cause quality to be decreased.

Probability is scaled linearly with quality effect. E.g. for `previous_probability = 1`, -100% quality effect means quality is always decreased, at -50% quality effect the quality is decreased 50% of the time and so on.

Must be >= 0.

Note: for a machine to have a negative quality effect, [EffectReceiver::quality_limits](prototype:EffectReceiver::quality_limits) needs to be set.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### previous_chain_probability

Probability of additional quality decrease happening after quality was decreased to reach this quality in the same crafting/mining operation.

Must be in range `[0, 1]`.

**Type:** `double`

**Optional:** Yes

**Default:** "clamp(`previous_probability * 0.1, 0, 1)`"

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

Must be >= 0.01.

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

### cargo_wagon_inventory_size_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `inventory_size_multiplier`"

### locomotive_power_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + 0.01 * `level`"

### rolling_stock_max_speed_multiplier

Must be >= 0.01.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + 0.01 * `level`"

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

Affects the durability of [tool items](prototype:ToolPrototype) like repair tools and armor.

**Type:** `double`

**Optional:** Yes

**Default:** "1 + `level`"

### science_capacity_multiplier

Must be >= 0.01.

Affects how much research will lab be able to do using item of that quality.

Only used for items that are not a [tool](prototype:ToolPrototype).

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `tool_durability_multiplier`"

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

Only affects beacons with [BeaconPrototype::quality_affects_supply_area_distance](prototype:BeaconPrototype::quality_affects_supply_area_distance) set.

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

### module_consumption_multiplier

Must be >= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### module_speed_multiplier

Must be >= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### module_productivity_multiplier

Must be >= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### module_pollution_multiplier

Must be >= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### module_quality_multiplier

Must be >= 0.01.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### spoil_ticks_multiplier

Must be >= 0.01.

Only affects items with [ItemPrototype::quality_affects_spoil_ticks](prototype:ItemPrototype::quality_affects_spoil_ticks) set.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_multiplier`"

### logistic_cell_charging_station_count_bonus

Only affects roboports with [RoboportPrototype::charging_station_count_affected_by_quality](prototype:RoboportPrototype::charging_station_count_affected_by_quality) set.

Only affects roboport equipment with [RoboportEquipmentPrototype::charging_station_count_affected_by_quality](prototype:RoboportEquipmentPrototype::charging_station_count_affected_by_quality) set.

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

