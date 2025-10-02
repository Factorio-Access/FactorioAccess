# LuaQualityPrototype

Prototype of a quality.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### color

The color of the prototype

**Read type:** `Color`

### level

Level basically specifies the stat-increasing value of this quality level.

**Read type:** `uint`

### next

The next higher level of the quality

**Read type:** `LuaQualityPrototype`

### next_probability

The probability multiplier of getting the next level of quality.

**Read type:** `double`

### draw_sprite_by_default

**Read type:** `boolean`

### beacon_power_usage_multiplier

**Read type:** `float`

### mining_drill_resource_drain_multiplier

**Read type:** `float`

### science_pack_drain_multiplier

**Read type:** `float`

### default_multiplier

**Read type:** `double`

### inserter_speed_multiplier

**Read type:** `double`

### fluid_wagon_capacity_multiplier

**Read type:** `double`

### inventory_size_multiplier

**Read type:** `double`

### lab_research_speed_multiplier

**Read type:** `double`

### crafting_machine_speed_multiplier

**Read type:** `double`

### crafting_machine_energy_usage_multiplier

**Read type:** `double`

### logistic_cell_charging_energy_multiplier

**Read type:** `double`

### tool_durability_multiplier

**Read type:** `double`

### accumulator_capacity_multiplier

**Read type:** `double`

### flying_robot_max_energy_multiplier

**Read type:** `double`

### range_multiplier

**Read type:** `double`

### equipment_grid_width_bonus

**Read type:** `int16`

### equipment_grid_height_bonus

**Read type:** `int16`

### electric_pole_wire_reach_bonus

**Read type:** `float`

### electric_pole_supply_area_distance_bonus

**Read type:** `float`

### beacon_supply_area_distance_bonus

**Read type:** `float`

### mining_drill_mining_radius_bonus

**Read type:** `float`

### logistic_cell_charging_station_count_bonus

**Read type:** `uint`

### asteroid_collector_collection_radius_bonus

**Read type:** `uint`

### beacon_module_slots_bonus

**Read type:** `ItemStackIndex`

### crafting_machine_module_slots_bonus

**Read type:** `ItemStackIndex`

### mining_drill_module_slots_bonus

**Read type:** `ItemStackIndex`

### lab_module_slots_bonus

**Read type:** `ItemStackIndex`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

