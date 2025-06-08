# LuaEntityPrototype

Prototype of an entity.

**Parent:** `LuaPrototypeBase`

## Methods

### get_crafting_speed

The crafting speed of this crafting-machine.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_fluid_usage_per_tick

The fluid usage of this generator prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_inserter_extension_speed

The extension speed of this inserter.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_inserter_rotation_speed

The rotation speed of this inserter.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_inventory_size

Gets the base size of the given inventory on this entity or `nil` if the given inventory doesn't exist.

**Parameters:**

- `index` `defines.inventory`: 
- `quality` `QualityID` _(optional)_: 

**Returns:**

- `uint`: 

### get_max_circuit_wire_distance

The maximum circuit wire distance for this entity. 0 if the entity doesn't support circuit wires.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_max_distance_of_nearby_sector_revealed

The radius of the area constantly revealed by this radar, or cargo landing pad, in chunks.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `uint`: 

### get_max_distance_of_sector_revealed

The radius of the area this radar can chart, in chunks.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `uint`: 

### get_max_energy

The max energy for this flying robot prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_max_energy_production

The theoretical maximum energy production for this entity.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_max_energy_usage

The theoretical maximum energy usage for this entity.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_max_health

Max health of this entity. Will be `0` if this is not an entity with health.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `float`: 

### get_max_power_output

The maximum power output of this burner generator or generator prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_max_wire_distance

The maximum wire distance for this entity. 0 if the entity doesn't support wires.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_pumping_speed

The pumping speed of this offshore or normal pump.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_researching_speed

The base researching speed of this lab prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_supply_area_distance

The supply area of this electric pole or beacon prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_valve_flow_rate

The maximum flow rate through this valve.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### has_flag

Test whether this entity prototype has a certain flag set.

**Parameters:**

- `flag` `EntityPrototypeFlag`: The flag to test.

**Returns:**

- `boolean`: `true` if this prototype has the given flag set.

## Attributes

### absorptions_to_join_attack

**Type:** `dictionary<`string`, `float`>` _(read-only)_

A table of pollutions amounts that has to be absorbed by the unit's spawner before the unit will leave the spawner and attack the source of the pollution, indexed by the name of each absorbed pollution type.

### accepted_seeds

**Type:** ``string`[]` _(read-only)_



### active_energy_usage

**Type:** `double` _(read-only)_

The active energy usage of this rocket silo or combinator prototype.

### additional_pastable_entities

**Type:** ``LuaEntityPrototype`[]` _(read-only)_

Entities this entity can be pasted onto in addition to the normal allowed ones.

### affected_by_tiles

**Type:** `boolean` _(read-only)_

Whether this unit prototype is affected by tile walking speed modifiers.

### agricultural_tower_radius

**Type:** `double` _(read-only)_



### air_resistance

**Type:** `double` _(read-only)_

The air resistance of this rolling stock prototype.

### alert_icon_scale

**Type:** `float` _(read-only)_

The alert icon scale of this entity prototype.

### alert_icon_shift

**Type:** `Vector` _(read-only)_

The alert icon shift of this entity prototype.

### alert_when_attacking

**Type:** `boolean` _(read-only)_

Whether this turret raises an alert when attacking

### alert_when_damaged

**Type:** `boolean` _(read-only)_

Whether this entity raises an alert when damaged.

### allow_access_to_all_forces

**Type:** `boolean` _(read-only)_

Whether this market allows access to all forces or just friendly ones.

### allow_burner_leech

**Type:** `boolean` _(read-only)_

Whether this inserter allows burner leeching.

### allow_copy_paste

**Type:** `boolean` _(read-only)_

When false copy-paste is not allowed for this entity.

### allow_custom_vectors

**Type:** `boolean` _(read-only)_

Whether this inserter allows custom pickup and drop vectors.

### allow_passengers

**Type:** `boolean` _(read-only)_

Whether this vehicle allows passengers.

### allow_run_time_change_of_is_military_target

**Type:** `boolean` _(read-only)_

True if this entity-with-owner's is_military_target can be changed run-time (on the entity, not on the prototype itself)

### allowed_effects

**Type:** `dictionary<`string`, `boolean`>` _(read-only)_

The allowed module effects for this entity, if any.

### allowed_module_categories

**Type:** `dictionary<`string`, `True`>` _(read-only)_

The allowed module categories for this entity, if any.

### always_on

**Type:** `boolean` _(read-only)_

Whether the lamp is always on (except when out of power or turned off by the circuit network).

### ammo_category

**Type:** `string` _(read-only)_

Name of the ammo category of this land mine.

### animation_speed_coefficient

**Type:** `double` _(read-only)_

The animation speed coefficient of this belt connectable prototype.

### attack_parameters

**Type:** `AttackParameters` _(read-only)_

The attack parameters for this entity, if any.

### attack_result

**Type:** ``TriggerItem`[]` _(read-only)_

The attack result of this entity, if any.

### auto_setup_collision_box

**Type:** `boolean` _(read-only)_



### automated_ammo_count

**Type:** `uint` _(read-only)_

The amount of ammo that inserters automatically insert into this ammo-turret or artillery-turret.

### automatic_weapon_cycling

**Type:** `boolean` _(read-only)_

Whether this spider vehicle prototype automatically cycles weapons.

### autoplace_specification

**Type:** `AutoplaceSpecification` _(read-only)_

Autoplace specification for this entity prototype, if any.

### beacon_counter

**Type:**  _(read-only)_

The beacon counter used by effect receiver when deciding which sample to take from beacon profile.

### belt_distance

**Type:** `double` _(read-only)_



### belt_length

**Type:** `double` _(read-only)_



### belt_speed

**Type:** `double` _(read-only)_

The speed of this transport belt.

### boiler_mode

**Type:**  _(read-only)_

The boiler operation mode of this boiler prototype.

### braking_force

**Type:** `double` _(read-only)_

The braking force of this vehicle prototype.

### build_base_evolution_requirement

**Type:** `double` _(read-only)_

The evolution requirement to build this entity as a base when expanding enemy bases.

### build_distance

**Type:** `uint` _(read-only)_



### building_grid_bit_shift

**Type:** `uint` _(read-only)_

The log2 of grid size of the building

### bulk

**Type:** `boolean` _(read-only)_

Whether this inserter is a bulk-type.

### burner_prototype

**Type:** `LuaBurnerPrototype` _(read-only)_

The burner energy source prototype this entity uses, if any.

### burns_fluid

**Type:** `boolean` _(read-only)_

Whether this generator prototype burns fluid.

### call_for_help_radius

**Type:** `double` _(read-only)_



### can_open_gates

**Type:** `boolean` _(read-only)_

Whether this unit prototype can open gates.

### chain_shooting_cooldown_modifier

**Type:** `double` _(read-only)_

The chain shooting cooldown modifier of this spider vehicle prototype.

### character_corpse

**Type:** `LuaEntityPrototype` _(read-only)_



### chunk_exploration_radius

**Type:** `double` _(read-only)_

The chunk exploration radius of this vehicle prototype.

### cliff_explosive_prototype

**Type:** `string` _(read-only)_

The item prototype name used to destroy this cliff.

### collision_box

**Type:** `BoundingBox` _(read-only)_

The bounding box used for collision checking.

### collision_mask

**Type:** `CollisionMask` _(read-only)_

The collision masks this entity uses

### collision_mask_collides_with_self

**Type:** `boolean` _(read-only)_

Does this prototype collision mask collide with itself?

### collision_mask_collides_with_tiles_only

**Type:** `boolean` _(read-only)_

Does this prototype collision mask collide with tiles only?

### collision_mask_considers_tile_transitions

**Type:** `boolean` _(read-only)_

Does this prototype collision mask consider tile transitions?

### color

**Type:** `Color` _(read-only)_

The color of the prototype, if any.

### connection_distance

**Type:** `double` _(read-only)_



### construction_radius

**Type:** `double` _(read-only)_

The construction radius for this roboport prototype.

### consumption

**Type:** `double` _(read-only)_

The energy consumption of this car prototype.

### container_distance

**Type:** `double` _(read-only)_



### corpses

**Type:** `dictionary<`string`, `LuaEntityPrototype`>` _(read-only)_

Corpses used when this entity is destroyed. It is a dictionary indexed by the corpse's prototype name.

### count_as_rock_for_filtered_deconstruction

**Type:** `boolean` _(read-only)_

If this simple-entity is counted as a rock for the deconstruction planner "trees and rocks only" filter.

### crafting_categories

**Type:** `dictionary<`string`, `True`>` _(read-only)_

The [crafting categories](runtime:LuaRecipeCategoryPrototype) this entity prototype supports.

The value in the dictionary is meaningless and exists just to allow for easy lookup.

### crane_energy_usage

**Type:** `double` _(read-only)_

The crane energy usage of this agricultural tower prototype.

### create_ghost_on_death

**Type:** `boolean` _(read-only)_

If this prototype will attempt to create a ghost of itself on death.

If this is false then a ghost will never be made, if it's true a ghost may be made.

### created_effect

**Type:** ``TriggerItem`[]` _(read-only)_

The trigger to run when this entity is created, if any.

### created_smoke

**Type:** `unknown` _(read-only)_

The smoke trigger run when this entity is built, if any.

### damage_hit_tint

**Type:** `Color` _(read-only)_



### darkness_for_all_lamps_off

**Type:** `float` _(read-only)_

Value between 0 and 1 darkness where all lamps of this lamp prototype are off.

### darkness_for_all_lamps_on

**Type:** `float` _(read-only)_

Value between 0 and 1 darkness where all lamps of this lamp prototype are on.

### destroy_non_fuel_fluid

**Type:** `boolean` _(read-only)_

Whether this generator prototype destroys non-fuel fluids.

### distraction_cooldown

**Type:** `uint` _(read-only)_

The distraction cooldown of this unit prototype.

### distribution_effectivity

**Type:** `double` _(read-only)_

The distribution effectivity for this beacon prototype.

### distribution_effectivity_bonus_per_quality_level

**Type:** `double` _(read-only)_

The distribution effectivity bonus per quality level for this beacon prototype.

### door_opening_speed

**Type:** `double` _(read-only)_

The door opening speed for this rocket silo prototype.

### draw_cargo

**Type:** `boolean` _(read-only)_

Whether this logistics or construction robot renders its cargo when flying.

### drawing_box_vertical_extension

**Type:** `double` _(read-only)_

Extra vertical space needed to see the whole entity in GUIs. This is used to calculate the correct zoom and positioning in the entity info gui, for example in the entity tooltip.

### drop_item_distance

**Type:** `uint` _(read-only)_



### dying_speed

**Type:** `float` _(read-only)_

The dying time of this corpse prototype.

### effect_receiver

**Type:** `EffectReceiver` _(read-only)_

Effect receiver prototype of this crafting machine, lab, or mining drill.

### effectivity

**Type:** `double` _(read-only)_

The effectivity of this car prototype, generator prototype.

### electric_energy_source_prototype

**Type:** `LuaElectricEnergySourcePrototype` _(read-only)_

The electric energy source prototype this entity uses, if any.

### emissions_per_second

**Type:** `dictionary<`string`, `double`>` _(read-only)_

A table of pollution emissions per second the entity will create, grouped by the name of the pollution type.

### enemy_map_color

**Type:** `Color` _(read-only)_

The enemy map color used when charting this entity.

### energy_per_hit_point

**Type:** `double` _(read-only)_

The energy used per hit point taken for this vehicle during collisions.

### energy_per_move

**Type:** `double` _(read-only)_

The energy consumed per tile moved for this flying robot.

### energy_per_tick

**Type:** `double` _(read-only)_

The energy consumed per tick for this flying robot.

### energy_usage

**Type:** `double` _(read-only)_

The direct energy usage of this entity, if any.

### engine_starting_speed

**Type:** `double` _(read-only)_

The engine starting speed for this rocket silo rocket prototype.

### enter_vehicle_distance

**Type:** `double` _(read-only)_



### explosion_beam

**Type:** `double` _(read-only)_

Whether this explosion has a beam.

### explosion_rotate

**Type:** `double` _(read-only)_

Whether this explosion rotates.

### factoriopedia_alternative

**Type:** `LuaEntityPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### fast_replaceable_group

**Type:** `string` _(read-only)_

The group of mutually fast-replaceable entities, if any.

### filter_count

**Type:** `uint` _(read-only)_

The filter count of this inserter, loader, mining drill or logistic chest. For logistic containers, `nil` means no limit.

### final_attack_result

**Type:** ``TriggerItem`[]` _(read-only)_

The final attack result for this projectile.

### fixed_recipe

**Type:** `string` _(read-only)_

The fixed recipe name for this assembling machine prototype, if any.

### flags

**Type:** `EntityPrototypeFlags` _(read-only)_

The flags for this entity prototype.

### flow_scaling

**Type:** `boolean` _(read-only)_



### fluid_capacity

**Type:** `double` _(read-only)_

The fluid capacity of this entity or 0 if this entity doesn't support fluids.

Crafting machines will report 0 due to their fluid capacity being whatever a given recipe needs.

### fluid_energy_source_prototype

**Type:** `LuaFluidEnergySourcePrototype` _(read-only)_

The fluid energy source prototype this entity uses, if any.

### fluid_source_offset

**Type:** `Vector` _(read-only)_



### fluid_usage_per_tick

**Type:** `double` _(read-only)_

The fluid usage of this generator prototype. This property is deprecated in favor of [LuaEntityPrototype::get_fluid_usage_per_tick](runtime:LuaEntityPrototype::get_fluid_usage_per_tick) and should not be used.

### fluidbox_prototypes

**Type:** ``LuaFluidBoxPrototype`[]` _(read-only)_

The fluidbox prototypes for this entity.

### flying_acceleration

**Type:** `double` _(read-only)_

The flying acceleration for this rocket silo rocket prototype.

### flying_speed

**Type:** `double` _(read-only)_

The flying speed for this rocket silo rocket prototype.

### friction_force

**Type:** `double` _(read-only)_

The friction of this vehicle prototype.

### friendly_map_color

**Type:** `Color` _(read-only)_

The friendly map color used when charting this entity.

### grid_prototype

**Type:** `LuaEquipmentGridPrototype` _(read-only)_

The equipment grid prototype for this entity, if any.

### growth_area_radius

**Type:** `double` _(read-only)_



### growth_grid_tile_size

**Type:** `uint` _(read-only)_



### growth_ticks

**Type:** `uint` _(read-only)_



### guns

**Type:** `dictionary<`string`, `LuaItemPrototype`>` _(read-only)_

A mapping of the gun name to the gun prototype this prototype uses. `nil` if this entity prototype doesn't use guns.

### harvest_emissions

**Type:** `dictionary<`string`, `double`>` _(read-only)_

A table of pollutants that this plant will release when it is harvested.

### has_belt_immunity

**Type:** `boolean` _(read-only)_

Whether this unit, car, or character prototype has belt immunity.

### healing_per_tick

**Type:** `float` _(read-only)_

Amount this entity can heal per tick, if any.

### heat_buffer_prototype

**Type:** `LuaHeatBufferPrototype` _(read-only)_

The heat buffer prototype this entity uses, if any.

### heat_energy_source_prototype

**Type:** `LuaHeatEnergySourcePrototype` _(read-only)_

The heat energy source prototype this entity uses, if any.

### heating_energy

**Type:** `double` _(read-only)_

The energy required to keep this entity from freezing. Zero energy means it doesn't freeze.

### height

**Type:** `double` _(read-only)_

The height of this spider vehicle prototype.

### indexed_guns

**Type:** ``LuaItemPrototype`[]` _(read-only)_

A vector of the gun prototypes of this car, spider vehicle, artillery wagon, or turret.

### infinite_depletion_resource_amount

**Type:** `uint` _(read-only)_

Every time this infinite resource 'ticks' down, it is reduced by this amount. Meaningless if this isn't an infinite resource.

### infinite_resource

**Type:** `boolean` _(read-only)_

Whether this resource is infinite.

### ingredient_count

**Type:** `uint` _(read-only)_

The max number of ingredients this crafting machine prototype supports.

### inserter_chases_belt_items

**Type:** `boolean` _(read-only)_

True if this inserter chases items on belts for pickup.

### inserter_drop_position

**Type:** `Vector` _(read-only)_

The drop position for this inserter.

### inserter_pickup_position

**Type:** `Vector` _(read-only)_

The pickup position for this inserter.

### inserter_stack_size_bonus

**Type:** `uint` _(read-only)_

The built-in stack size bonus of this inserter prototype.

### instruments

**Type:** ``ProgrammableSpeakerInstrument`[]` _(read-only)_

The instruments for this programmable speaker.

### inventory_type

**Type:**  _(read-only)_

The inventory type this container or linked container uses.

### is_building

**Type:** `boolean` _(read-only)_



### is_entity_with_owner

**Type:** `boolean` _(read-only)_

True if this is entity-with-owner

### is_military_target

**Type:** `boolean` _(read-only)_

True if this entity-with-owner is military target

### item_pickup_distance

**Type:** `double` _(read-only)_



### items_to_place_this

**Type:** ``ItemStackDefinition`[]` _(read-only)_

Items that when placed will produce this entity, if any. Construction bots will choose the first item in the list to build this entity.

### joint_distance

**Type:** `double` _(read-only)_



### lab_inputs

**Type:** ``string`[]` _(read-only)_

The item prototype names that are the inputs of this lab prototype.

### lamp_energy_usage

**Type:** `double` _(read-only)_

The lamp energy usage of this rocket silo prototype.

### launch_to_space_platforms

**Type:** `boolean` _(read-only)_



### launch_wait_time

**Type:** `uint8` _(read-only)_

The rocket launch delay for this rocket silo prototype.

### light_blinking_speed

**Type:** `double` _(read-only)_

The light blinking speed for this rocket silo prototype.

### loader_adjustable_belt_stack_size

**Type:** `boolean` _(read-only)_

True if this loader supports a runtime-adjustable belt stack size.

### loader_max_belt_stack_size

**Type:** `uint8` _(read-only)_

The max belt stack size for this loader.

### logistic_mode

**Type:**  _(read-only)_

The logistic mode of this logistic container.

### logistic_parameters

**Type:** `unknown` _(read-only)_

The logistic parameters for this roboport.

### logistic_radius

**Type:** `double` _(read-only)_

The logistic radius for this roboport prototype.

### loot

**Type:** ``Loot`[]` _(read-only)_

Loot that will be dropped when this entity is killed, if any.

### loot_pickup_distance

**Type:** `double` _(read-only)_



### manual_range_modifier

**Type:** `double` _(read-only)_

The manual range modifier for this artillery turret or wagon prototype.

### map_color

**Type:** `Color` _(read-only)_

The map color used when charting this entity if a friendly or enemy color isn't defined, if any.

### map_generator_bounding_box

**Type:** `BoundingBox` _(read-only)_

The bounding box used for map generator collision checking.

### max_count_of_owned_defensive_units

**Type:** `double` _(read-only)_

Count of defensive enemies this spawner can sustain.

### max_count_of_owned_units

**Type:** `double` _(read-only)_

Count of enemies this spawner can sustain.

### max_darkness_to_spawn

**Type:** `float` _(read-only)_

The maximum darkness at which this unit spawner can spawn entities.

### max_defensive_friends_around_to_spawn

**Type:** `double` _(read-only)_

How many defensive friendly units are required within the spawning_radius of this spawner for it to stop producing more units.

### max_friends_around_to_spawn

**Type:** `double` _(read-only)_

How many friendly units are required within the spawning_radius of this spawner for it to stop producing more units.

### max_item_product_count

**Type:** `uint` _(read-only)_

The max number of item products this crafting machine prototype supports.

### max_payload_size

**Type:** `uint` _(read-only)_

The max payload size of this logistics or construction robot.

### max_polyphony

**Type:** `uint` _(read-only)_

The maximum polyphony for this programmable speaker.

### max_power_output

**Type:** `double` _(read-only)_

The default maximum power output of this generator prototype. This property is deprecated in favor of [LuaEntityPrototype::get_max_power_output](runtime:LuaEntityPrototype::get_max_power_output) and should not be used.

### max_pursue_distance

**Type:** `double` _(read-only)_

The maximum pursue distance of this unit prototype.

### max_speed

**Type:** `double` _(read-only)_

The max speed of this projectile or flying robot prototype.

### max_to_charge

**Type:** `float` _(read-only)_

The maximum energy for this flying robot above which it won't try to recharge when stationing.

### max_underground_distance

**Type:** `uint8` _(read-only)_

The max underground distance for underground belts and underground pipes.

### maximum_corner_sliding_distance

**Type:** `double` _(read-only)_



### maximum_temperature

**Type:** `double` _(read-only)_

The maximum fluid temperature of this generator prototype.

### min_darkness_to_spawn

**Type:** `float` _(read-only)_

The minimum darkness at which this unit spawner can spawn entities.

### min_pursue_time

**Type:** `uint` _(read-only)_

The minimum pursue time of this unit prototype.

### min_to_charge

**Type:** `float` _(read-only)_

The minimum energy for this flying robot before it tries to recharge.

### mineable_properties

**Type:** `MineableProperties` _(read-only)_

Whether this entity is minable and what can be obtained by mining it.

### minimum_resource_amount

**Type:** `uint` _(read-only)_

Minimum amount of this resource.

### mining_drill_radius

**Type:** `double` _(read-only)_

The mining radius of this mining drill prototype.

### mining_speed

**Type:** `double` _(read-only)_

The mining speed of this mining drill/character prototype.

### module_inventory_size

**Type:** `uint` _(read-only)_

The module inventory size. `nil` if this entity doesn't support modules.

### move_while_shooting

**Type:** `boolean` _(read-only)_

Whether this unit prototype can move while shooting.

### neighbour_bonus

**Type:** `double` _(read-only)_



### next_upgrade

**Type:** `LuaEntityPrototype` _(read-only)_

The next upgrade for this entity, if any.

### normal_resource_amount

**Type:** `uint` _(read-only)_

The normal amount for this resource.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### per_lane_filters

**Type:** `boolean` _(read-only)_



### profile

**Type:** ``double`[]` _(read-only)_

The beacon profile: extra multiplier applied to the effects received from beacon by the effect receiver based on amount of beacons that reach that effect receiver

### protected_from_tile_building

**Type:** `boolean` _(read-only)_

True if this entity prototype should be included during tile collision checks with [LuaTilePrototype::check_collision_with_entities](runtime:LuaTilePrototype::check_collision_with_entities) enabled.

### pumping_speed

**Type:** `double` _(read-only)_

The pumping speed of this offshore or normal pump. This property is deprecated in favor of [LuaEntityPrototype::get_pumping_speed](runtime:LuaEntityPrototype::get_pumping_speed) and should not be used.

### radar_range

**Type:** `uint` _(read-only)_

The radar range of this unit prototype.

### radius

**Type:** `double` _(read-only)_

The radius of this entity prototype.

### radius_visualisation_specification

**Type:** `RadiusVisualisationSpecification` _(read-only)_



### reach_distance

**Type:** `uint` _(read-only)_



### reach_resource_distance

**Type:** `double` _(read-only)_



### related_underground_belt

**Type:** `LuaEntityPrototype` _(read-only)_



### remains_when_mined

**Type:** ``LuaEntityPrototype`[]` _(read-only)_

The remains left behind when this entity is mined.

### remove_decoratives

**Type:**  _(read-only)_

Whether this entity should remove decoratives that collide with it when this entity is built.

### repair_speed_modifier

**Type:** `float` _(read-only)_

Repair-speed modifier for this entity, if any. Actual repair speed will be `tool_repair_speed * entity_repair_speed_modifier`.

### resistances

**Type:** `dictionary<`string`, `Resistance`>` _(read-only)_

List of resistances towards each damage type. It is a dictionary indexed by damage type names (see `data/base/prototypes/damage-type.lua`).

### resource_categories

**Type:** `dictionary<`string`, `True`>` _(read-only)_

The [resource categories](runtime:LuaResourceCategoryPrototype) this character or mining drill supports.

The value in the dictionary is meaningless and exists just to allow for easy lookup.

### resource_category

**Type:** `string` _(read-only)_

Name of the category of this resource.

During data stage, this property is named "category".

### resource_drain_rate_percent

**Type:** `uint8` _(read-only)_

The resource drain rate percent of this mining drill prototype.

### respawn_time

**Type:** `uint` _(read-only)_



### result_units

**Type:** ``UnitSpawnDefinition`[]` _(read-only)_

The result units and spawn points with weight and evolution factor for a biter spawner entity.

### rewire_neighbours_when_destroying

**Type:** `boolean` _(read-only)_



### rising_speed

**Type:** `double` _(read-only)_

The rising speed for this rocket silo rocket prototype.

### rocket_entity_prototype

**Type:** `LuaEntityPrototype` _(read-only)_

The rocket entity prototype associated with this rocket silo prototype.

### rocket_parts_required

**Type:** `uint` _(read-only)_

The rocket parts required for this rocket silo prototype.

### rocket_rising_delay

**Type:** `uint8` _(read-only)_

The rocket rising delay for this rocket silo prototype.

### rotation_snap_angle

**Type:** `double` _(read-only)_

The rotation snap angle of this car prototype.

### rotation_speed

**Type:** `double` _(read-only)_

The rotation speed of this car prototype.

### running_speed

**Type:** `double` _(read-only)_

The movement speed of this character prototype.

### scale_fluid_usage

**Type:** `boolean` _(read-only)_

Whether this generator prototype scales fluid usage.

### science_pack_drain_rate_percent

**Type:** `uint8` _(read-only)_

How much science pack durability is required to research one science point.

### secondary_collision_box

**Type:** `BoundingBox` _(read-only)_

The secondary bounding box used for collision checking, if any. This is only used in rails and rail remnants.

### selectable_in_game

**Type:** `boolean` _(read-only)_

Is this entity selectable?

### selection_box

**Type:** `BoundingBox` _(read-only)_

The bounding box used for drawing selection.

### selection_priority

**Type:** `uint` _(read-only)_

The selection priority of this entity - a value between `0` and `255`.

### shooting_cursor_size

**Type:** `float` _(read-only)_

The cursor size used when shooting at this entity.

### solar_panel_performance_at_day

**Type:** `double` _(read-only)_



### solar_panel_performance_at_night

**Type:** `double` _(read-only)_



### solar_panel_solar_coefficient_property

**Type:** `LuaSurfacePropertyPrototype` _(read-only)_



### spawn_cooldown

**Type:** `unknown` _(read-only)_

The spawning cooldown for this enemy spawner prototype.

### spawn_decoration

**Type:** ``TriggerEffectItem`[]` _(read-only)_



### spawn_decorations_on_expansion

**Type:** `boolean` _(read-only)_



### spawning_radius

**Type:** `double` _(read-only)_

How far from the spawner can the units be spawned.

### spawning_spacing

**Type:** `double` _(read-only)_

What spaces should be between the spawned units.

### spawning_time_modifier

**Type:** `double` _(read-only)_

The spawning time modifier of this unit prototype.

### speed

**Type:** `double` _(read-only)_

The default speed of this flying robot, rolling stock or unit. For rolling stocks, this is their `max_speed`.

### speed_multiplier_when_out_of_energy

**Type:** `float` _(read-only)_

The speed multiplier when this flying robot is out of energy.

### sticker_box

**Type:** `BoundingBox` _(read-only)_

The bounding box used to attach sticker type entities.

### supports_direction

**Type:** `boolean` _(read-only)_

Whether this entity prototype could possibly ever be rotated.

### surface_conditions

**Type:** ``SurfaceCondition`[]` _(read-only)_

The surface conditions required to build this entity.

### tank_driving

**Type:** `boolean` _(read-only)_

If this car prototype uses tank controls to drive.

### target_temperature

**Type:** `float` _(read-only)_

The target temperature of this boiler or fusion reactor prototype. If `nil` on a fusion reactor, the target temperature is the default temperature of the output fluid.

### terrain_friction_modifier

**Type:** `float` _(read-only)_

The terrain friction modifier for this vehicle.

### ticks_to_keep_aiming_direction

**Type:** `uint` _(read-only)_



### ticks_to_keep_gun

**Type:** `uint` _(read-only)_



### ticks_to_stay_in_combat

**Type:** `uint` _(read-only)_



### tile_height

**Type:** `uint` _(read-only)_

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension)

### tile_width

**Type:** `uint` _(read-only)_

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension)

### time_to_live

**Type:** `uint` _(read-only)_

The time to live for this prototype or `0` if prototype doesn't have time_to_live or time_before_removed.

### timeout

**Type:** `uint` _(read-only)_

The time it takes this land mine to arm.

### torso_bob_speed

**Type:** `double` _(read-only)_

The torso bob speed of this spider vehicle prototype.

### torso_rotation_speed

**Type:** `double` _(read-only)_

The torso rotation speed of this spider vehicle prototype.

### tree_color_count

**Type:** `uint8` _(read-only)_

If it is a tree, return the number of colors it supports.

### trigger_collision_mask

**Type:** `CollisionMask` _(read-only)_

The collision mask entities must collide with to make this landmine blow up.

### trigger_target_mask

**Type:** `dictionary<`string`, `boolean`>` _(read-only)_

The trigger target mask for this entity prototype type.

The values in the dictionary are meaningless and exists just to allow the dictionary type for easy lookup.

### turret_range

**Type:** `uint` _(read-only)_

The range of this turret.

### turret_rotation_speed

**Type:** `float` _(read-only)_

The turret rotation speed of this car prototype.

### use_exact_mode

**Type:** `boolean` _(read-only)_

Whether this logistic container prototype uses exact mode

### uses_force_mining_productivity_bonus

**Type:** `boolean` _(read-only)_

If this drill uses force productivity bonus

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### valve_mode

**Type:** `ValveMode` _(read-only)_

The mode of operation of this valve.

### valve_threshold

**Type:** `float` _(read-only)_

The default threshold of this valve.

### vector_to_place_result

**Type:** `Vector` _(read-only)_



### vertical_selection_shift

**Type:** `double` _(read-only)_

Vertical selection shift used by rolling stocks. It affects selection box vertical position but is also used to shift rolling stock graphics along the rails to fine tune train's look.

### vision_distance

**Type:** `double` _(read-only)_

The vision distance of this unit prototype.

### void_energy_source_prototype

**Type:** `LuaVoidEnergySourcePrototype` _(read-only)_

The void energy source prototype this entity uses, if any.

### weight

**Type:** `double` _(read-only)_

The weight of this vehicle prototype.

