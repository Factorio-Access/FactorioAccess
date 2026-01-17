# LuaEntityPrototype

Prototype of an entity.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### infinite_resource

Whether this resource is infinite.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** ResourceEntity

### minimum_resource_amount

Minimum amount of this resource.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** ResourceEntity

### normal_resource_amount

The normal amount for this resource.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** ResourceEntity

### infinite_depletion_resource_amount

Every time this infinite resource 'ticks' down, it is reduced by this amount. Meaningless if this isn't an infinite resource.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** ResourceEntity

### resource_category

Name of the category of this resource.

During data stage, this property is named "category".

**Read type:** `string`

**Optional:** Yes

**Subclasses:** ResourceEntity

### mineable_properties

Whether this entity is minable and what can be obtained by mining it.

**Read type:** `MineableProperties`

### items_to_place_this

Items that when placed will produce this entity, if any. Construction bots will choose the first item in the list to build this entity.

**Read type:** Array[`ItemToPlace`]

**Optional:** Yes

### collision_box

The bounding box used for collision checking.

**Read type:** `BoundingBox`

### secondary_collision_box

The secondary bounding box used for collision checking, if any. This is only used in rails and rail remnants.

**Read type:** `BoundingBox`

**Optional:** Yes

### map_generator_bounding_box

The bounding box used for map generator collision checking.

**Read type:** `BoundingBox`

### selection_box

The bounding box used for drawing selection.

**Read type:** `BoundingBox`

### drawing_box_vertical_extension

Extra vertical space needed to see the whole entity in GUIs. This is used to calculate the correct zoom and positioning in the entity info gui, for example in the entity tooltip.

**Read type:** `double`

### sticker_box

The bounding box used to attach sticker type entities.

**Read type:** `BoundingBox`

### collision_mask

The collision masks this entity uses

**Read type:** `CollisionMask`

### trigger_target_mask

The trigger target mask for this entity prototype type.

The values in the dictionary are meaningless and exists just to allow the dictionary type for easy lookup.

**Read type:** Dictionary[`string`, `boolean`]

### healing_per_tick

Amount this entity can heal per tick, if any.

**Read type:** `float`

**Optional:** Yes

### emissions_per_second

A table of pollution emissions per second the entity will create, grouped by the name of the pollution type.

**Read type:** Dictionary[`string`, `double`]

### corpses

Corpses used when this entity is destroyed. It is a dictionary indexed by the corpse's prototype name.

**Read type:** Dictionary[`string`, `LuaEntityPrototype`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### selectable_in_game

Is this entity selectable?

**Read type:** `boolean`

### selection_priority

The selection priority of this entity - a value between `0` and `255`.

**Read type:** `uint32`

### weight

The weight of this vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Vehicle

### resistances

List of resistances towards each damage type. It is a dictionary indexed by damage type names (see `data/base/prototypes/damage-type.lua`).

**Read type:** Dictionary[`string`, `Resistance`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### fast_replaceable_group

The group of mutually fast-replaceable entities, if any.

**Read type:** `string`

**Optional:** Yes

### next_upgrade

The next upgrade for this entity, if any.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### icons_positioning

The icon positioning for inventories of this entity, if defined.

**Read type:** Array[`IconSequencePositioning`]

**Optional:** Yes

### icon_draw_specification

The definition of where and how the alt-mode icons of this entity should be drawn.

**Read type:** `IconDrawSpecification`

### loot

Loot that will be dropped when this entity is killed, if any.

**Read type:** Array[`Loot`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### repair_speed_modifier

Repair-speed modifier for this entity, if any. Actual repair speed will be `tool_repair_speed * entity_repair_speed_modifier`.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** EntityWithHealth

### turret_range

The range of this turret.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Turret

### autoplace_specification

Autoplace specification for this entity prototype, if any.

**Read type:** `AutoplaceSpecification`

**Optional:** Yes

### belt_speed

The speed of this transport belt.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** TransportBeltConnectable

### result_units

The result units and spawn points with weight and evolution factor for a biter spawner entity.

**Read type:** Array[`UnitSpawnDefinition`]

**Optional:** Yes

**Subclasses:** Spawner

### attack_result

The attack result of this entity, if any.

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

### final_attack_result

The final attack result for this projectile.

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

**Subclasses:** Projectile

### attack_parameters

The attack parameters for this entity, if any.

**Read type:** `AttackParameters`

**Optional:** Yes

### revenge_attack_parameters

The revenge attack parameters for this entity, if any. These attack parameters are used in addition to [LuaEntityPrototype::attack_parameters](runtime:LuaEntityPrototype::attack_parameters) if the entity is attacking a target that has previously dealt damage to the entity.

**Read type:** `AttackParameters`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### spawn_cooldown

The spawning cooldown for this enemy spawner prototype.

**Read type:** Table (see below for parameters)

**Optional:** Yes

**Subclasses:** Spawner

### mining_drill_radius

The mining radius of this mining drill prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** MiningDrill

### quality_affects_mining_radius

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** MiningDrill

### mining_speed

The mining speed of this mining drill/character prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** MiningDrill, Character

### resource_drain_rate_percent

The resource drain rate percent of this mining drill prototype.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** MiningDrill

### uses_force_mining_productivity_bonus

If this drill uses force productivity bonus

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** MiningDrill

### logistic_mode

The logistic mode of this logistic container.

**Read type:** `"requester"` | `"active-provider"` | `"passive-provider"` | `"buffer"` | `"storage"` | `"none"`

**Optional:** Yes

**Subclasses:** LogisticContainer

### max_underground_distance

The max underground distance for underground belts and underground pipes.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** UndergroundBelt, PipeToGround

### flags

The flags for this entity prototype.

**Read type:** `EntityPrototypeFlags`

### remains_when_mined

The remains left behind when this entity is mined.

**Read type:** Array[`LuaEntityPrototype`]

### additional_pastable_entities

Entities this entity can be pasted onto in addition to the normal allowed ones.

**Read type:** Array[`LuaEntityPrototype`]

### allow_copy_paste

When false copy-paste is not allowed for this entity.

**Read type:** `boolean`

### shooting_cursor_size

The cursor size used when shooting at this entity.

**Read type:** `float`

### created_smoke

The smoke trigger run when this entity is built, if any.

**Read type:** Table (see below for parameters)

**Optional:** Yes

### created_effect

The trigger to run when this entity is created, if any.

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

### update_effects

The trigger effects to run every tick when on cooldown.

**Read type:** Array[`TriggerEffectWithCooldown`]

**Optional:** Yes

**Subclasses:** Segment

### update_effects_while_enraged

The trigger effects to run every tick when on cooldown while the owning [LuaSegmentedUnit](runtime:LuaSegmentedUnit) is enraged.

**Read type:** Array[`TriggerEffectWithCooldown`]

**Optional:** Yes

**Subclasses:** Segment

### map_color

The map color used when charting this entity if a friendly or enemy color isn't defined, if any.

**Read type:** `Color`

**Optional:** Yes

### friendly_map_color

The friendly map color used when charting this entity.

**Read type:** `Color`

### enemy_map_color

The enemy map color used when charting this entity.

**Read type:** `Color`

### build_base_evolution_requirement

The evolution requirement to build this entity as a base when expanding enemy bases.

**Read type:** `double`

### instruments

The instruments for this programmable speaker.

**Read type:** Array[`ProgrammableSpeakerInstrument`]

**Optional:** Yes

**Subclasses:** ProgrammableSpeaker

### max_polyphony

The maximum polyphony for this programmable speaker.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** ProgrammableSpeaker

### module_inventory_size

The module inventory size. `nil` if this entity doesn't support modules.

**Read type:** `uint32`

**Optional:** Yes

### quality_affects_module_slots

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Beacon, CraftingMachine, MiningDrill, Lab

### inventory_type

The inventory type this container or linked container uses.

**Read type:** `"normal"` | `"with_bar"` | `"with_filters"` | `"with_filters_and_bar"` | `"with_weight_limit"` | `"with_custom_stack_size"`

**Optional:** Yes

**Subclasses:** ContainerEntity, LinkedContainer

### inventory_weight_limit

Weight limit of the inventory if inventory_type is `"with_weight_limit"`.

**Read type:** `Weight`

**Optional:** Yes

**Subclasses:** ContainerEntity, LinkedContainer

### inventory_properties

Properties of custom inventory. Only provided if inventory_type is `"with_custom_stack_size"`.

**Read type:** `InventoryWithCustomStackSizeSpecification`

**Optional:** Yes

**Subclasses:** ContainerEntity, LinkedContainer

### ingredient_count

The max number of ingredients this crafting machine prototype supports.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** CraftingMachine

### max_item_product_count

The max number of item products this crafting machine prototype supports.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** CraftingMachine

### crafting_categories

The [crafting categories](runtime:LuaRecipeCategoryPrototype) this entity prototype supports.

The value in the dictionary is meaningless and exists just to allow for easy lookup.

**Read type:** Dictionary[`string`, `True`]

**Optional:** Yes

**Subclasses:** CraftingMachine, Character

### resource_categories

The [resource categories](runtime:LuaResourceCategoryPrototype) this character or mining drill supports.

The value in the dictionary is meaningless and exists just to allow for easy lookup.

**Read type:** Dictionary[`string`, `True`]

**Optional:** Yes

**Subclasses:** MiningDrill, Character

### energy_usage

The direct energy usage of this entity, if any.

**Read type:** `double`

**Optional:** Yes

### effectivity

The effectivity of this car prototype, generator prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Car, Generator, FusionGenerator

### consumption

The energy consumption of this car prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Car

### friction_force

The friction of this vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Vehicle

### braking_force

The braking force of this vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Vehicle

### air_resistance

The air resistance of this rolling stock prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RollingStock

### tank_driving

If this car prototype uses tank controls to drive.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Car

### rotation_speed

The rotation speed of this car prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Car

### rotation_snap_angle

The rotation snap angle of this car prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Car

### turret_rotation_speed

The turret rotation speed of this car prototype.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Car

### guns

A mapping of the gun name to the gun prototype this prototype uses. `nil` if this entity prototype doesn't use guns.

**Read type:** Dictionary[`string`, `LuaItemPrototype`]

**Optional:** Yes

### indexed_guns

A vector of the gun prototypes of this car, spider vehicle, artillery wagon, or turret.

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

**Subclasses:** Car, SpiderVehicle, ArtilleryTurret, ArtilleryWagon

### speed

The default speed of this flying robot, rolling stock or unit. For rolling stocks, this is their `max_speed`.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** FlyingRobot, RollingStock, Unit

### speed_multiplier_when_out_of_energy

The speed multiplier when this flying robot is out of energy.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** FlyingRobot

### max_payload_size

The cargo carrying capacity of this logistics or construction robot.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** RobotWithLogisticsInterface

### max_payload_size_after_bonus

The maximum possible cargo carrying capacity of this logistics or construction robot. Bonuses from technologies/forces can't increase the carrying capacity beyond this number.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** RobotWithLogisticsInterface

### draw_cargo

Whether this logistics or construction robot renders its cargo when flying.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** RobotWithLogisticsInterface

### energy_per_move

The energy consumed per tile moved for this flying robot.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** FlyingRobot

### energy_per_tick

The energy consumed per tick for this flying robot.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** FlyingRobot

### min_to_charge

The minimum energy for this flying robot before it tries to recharge.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** FlyingRobot

### max_to_charge

The maximum energy for this flying robot above which it won't try to recharge when stationing.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** FlyingRobot

### burner_prototype

The burner energy source prototype this entity uses, if any.

**Read type:** `LuaBurnerPrototype`

**Optional:** Yes

### electric_energy_source_prototype

The electric energy source prototype this entity uses, if any.

**Read type:** `LuaElectricEnergySourcePrototype`

**Optional:** Yes

### heat_energy_source_prototype

The heat energy source prototype this entity uses, if any.

**Read type:** `LuaHeatEnergySourcePrototype`

**Optional:** Yes

### fluid_energy_source_prototype

The fluid energy source prototype this entity uses, if any.

**Read type:** `LuaFluidEnergySourcePrototype`

**Optional:** Yes

### void_energy_source_prototype

The void energy source prototype this entity uses, if any.

**Read type:** `LuaVoidEnergySourcePrototype`

**Optional:** Yes

### heat_buffer_prototype

The heat buffer prototype this entity uses, if any.

**Read type:** `LuaHeatBufferPrototype`

**Optional:** Yes

### building_grid_bit_shift

The log2 of [grid size](prototype:EntityPrototype::build_grid_size) of the building.

**Read type:** `uint32`

### fluid_usage_per_tick

The fluid usage of this generator prototype. This property is deprecated in favor of [LuaEntityPrototype::get_fluid_usage_per_tick](runtime:LuaEntityPrototype::get_fluid_usage_per_tick) and should not be used.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Generator

### maximum_temperature

The maximum fluid temperature of this generator prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Generator

### burns_fluid

Whether this generator prototype burns fluid.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Generator, FusionGenerator

### scale_fluid_usage

Whether this generator prototype scales fluid usage.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Generator

### destroy_non_fuel_fluid

Whether this generator prototype destroys non-fuel fluids.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Generator

### max_power_output

The default maximum power output of this generator prototype. This property is deprecated in favor of [LuaEntityPrototype::get_max_power_output](runtime:LuaEntityPrototype::get_max_power_output) and should not be used.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** BurnerGenerator, Generator

### target_temperature

The target temperature of this boiler or fusion reactor prototype. If `nil` on a fusion reactor, the target temperature is the default temperature of the output fluid.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Boiler, FusionReactor

### boiler_mode

The boiler operation mode of this boiler prototype.

**Read type:** `"heat-fluid-inside"` | `"output-to-separate-pipe"`

**Optional:** Yes

**Subclasses:** Boiler

### fluid_capacity

The fluid capacity of this entity or 0 if this entity doesn't support fluids.

Crafting machines will report 0 due to their fluid capacity being whatever a given recipe needs.

**Read type:** `double`

### pumping_speed

The pumping speed of this offshore pump or normal pump. This property is deprecated in favor of [LuaEntityPrototype::get_pumping_speed](runtime:LuaEntityPrototype::get_pumping_speed) and should not be used.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** OffshorePump, Pump

### valve_mode

The mode of operation of this valve.

**Read type:** `ValveMode`

**Optional:** Yes

**Subclasses:** Valve

### valve_threshold

The default threshold of this valve.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Valve

### bulk

Whether this inserter is a bulk-type.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Inserter

### uses_inserter_stack_size_bonus

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Inserter

### fluid_source_offset

**Read type:** `Vector`

**Optional:** Yes

**Subclasses:** OffshorePump

### flow_scaling

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Pump

### allow_custom_vectors

Whether this inserter allows custom pickup and drop vectors.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Inserter

### allow_burner_leech

Whether this inserter allows burner leeching.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Inserter

### inserter_pickup_position

The pickup position for this inserter.

**Read type:** `Vector`

**Optional:** Yes

**Subclasses:** Inserter

### inserter_drop_position

The drop position for this inserter.

**Read type:** `Vector`

**Optional:** Yes

**Subclasses:** Inserter

### inserter_chases_belt_items

True if this inserter chases items on belts for pickup.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Inserter

### loader_max_belt_stack_size

The max belt stack size for this loader.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** Loader

### loader_adjustable_belt_stack_size

True if this loader supports a runtime-adjustable belt stack size.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Loader

### loader_wait_for_full_stack

True if this loader will not drop items for which total amount is less than a full belt stack.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Loader

### loader_respect_insert_limits

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Loader

### count_as_rock_for_filtered_deconstruction

If this simple-entity is counted as a rock for the deconstruction planner "trees and rocks only" filter.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** SimpleEntity

### filter_count

The filter count of this inserter, loader, mining drill or logistic chest. For logistic containers, `nil` means no limit.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Inserter, Loader, LogisticContainer, MiningDrill

### time_to_live

The time to live for this prototype or `0` if prototype doesn't have time_to_live or time_before_removed.

**Read type:** `uint32`

### distribution_effectivity

The distribution effectivity for this beacon prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Beacon

### distribution_effectivity_bonus_per_quality_level

The distribution effectivity bonus per quality level for this beacon prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Beacon

### profile

The beacon profile: extra multiplier applied to the effects received from beacon by the effect receiver based on amount of beacons that reach that effect receiver

**Read type:** Array[`double`]

**Optional:** Yes

**Subclasses:** Beacon

### beacon_counter

The beacon counter used by effect receiver when deciding which sample to take from beacon profile.

**Read type:** `"total"` | `"same_type"`

**Optional:** Yes

**Subclasses:** Beacon

### explosion_beam

Whether this explosion has a beam.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Explosion

### explosion_rotate

Whether this explosion rotates.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Explosion

### tree_color_count

If it is a tree, return the number of colors it supports.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** Tree

### alert_when_damaged

Whether this entity raises an alert when damaged.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** EntityWithHealth

### alert_when_attacking

Whether this turret raises an alert when attacking

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Turret

### color

The color of the prototype, if any.

**Read type:** `Color`

**Optional:** Yes

### collision_mask_collides_with_self

Does this prototype collision mask collide with itself?

**Read type:** `boolean`

### collision_mask_collides_with_tiles_only

Does this prototype collision mask collide with tiles only?

**Read type:** `boolean`

### collision_mask_considers_tile_transitions

Does this prototype collision mask consider tile transitions?

**Read type:** `boolean`

### allowed_effects

The allowed module effects for this entity, if any.

**Read type:** Dictionary[`string`, `boolean`]

**Optional:** Yes

### allowed_module_categories

The allowed module categories for this entity, if any.

**Read type:** Dictionary[`string`, `True`]

**Optional:** Yes

### rocket_parts_required

The rocket parts required for this rocket silo prototype.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** RocketSilo

### rocket_rising_delay

The rocket rising delay for this rocket silo prototype.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** RocketSilo

### launch_wait_time

The rocket launch delay for this rocket silo prototype.

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** RocketSilo

### light_blinking_speed

The light blinking speed for this rocket silo prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSilo

### door_opening_speed

The door opening speed for this rocket silo prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSilo

### launch_to_space_platforms

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** RocketSilo

### rising_speed

The rising speed for this rocket silo rocket prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSiloRocket

### engine_starting_speed

The engine starting speed for this rocket silo rocket prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSiloRocket

### flying_speed

The flying speed for this rocket silo rocket prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSiloRocket

### flying_acceleration

The flying acceleration for this rocket silo rocket prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSiloRocket

### fixed_recipe

The fixed recipe name for this assembling machine prototype, if any.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** AssemblingMachine

### construction_radius

The construction radius for this roboport prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Roboport

### logistic_radius

The logistic radius for this roboport prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Roboport

### energy_per_hit_point

The energy used per hit point taken for this vehicle during collisions.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Vehicle

### create_ghost_on_death

If this prototype will attempt to create a ghost of itself on death.

If this is false then a ghost will never be made, if it's true a ghost may be made.

**Read type:** `boolean`

### ammo_category

Name of the ammo category of this land mine.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** LandMine

### timeout

The time it takes this land mine to arm.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** LandMine

### trigger_collision_mask

The collision mask entities must collide with to make this landmine blow up.

**Read type:** `CollisionMask`

**Optional:** Yes

**Subclasses:** LandMine

### fluidbox_prototypes

The fluidbox prototypes for this entity.

**Read type:** Array[`LuaFluidBoxPrototype`]

### neighbour_bonus

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Reactor, FusionReactor

### container_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Loader

### belt_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Loader

### belt_length

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Loader

### per_lane_filters

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Loader

### is_building

**Read type:** `boolean`

### automated_ammo_count

The amount of ammo that inserters automatically insert into this ammo-turret or artillery-turret.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** ArtilleryTurret, AmmoTurret

### max_speed

The max speed of this projectile or flying robot prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Projectile, FlyingRobot

### darkness_for_all_lamps_on

Value between 0 and 1 darkness where all lamps of this lamp prototype are on.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Lamp

### darkness_for_all_lamps_off

Value between 0 and 1 darkness where all lamps of this lamp prototype are off.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Lamp

### always_on

Whether the lamp is always on (except when out of power or turned off by the circuit network).

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Lamp

### min_darkness_to_spawn

The minimum darkness at which this unit spawner can spawn entities.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Spawner

### max_darkness_to_spawn

The maximum darkness at which this unit spawner can spawn entities.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Spawner

### call_for_help_radius

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### max_count_of_owned_units

Count of enemies this spawner can sustain.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### max_count_of_owned_defensive_units

Count of defensive enemies this spawner can sustain.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### max_friends_around_to_spawn

How many friendly units are required within the spawning_radius of this spawner for it to stop producing more units.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### max_defensive_friends_around_to_spawn

How many defensive friendly units are required within the spawning_radius of this spawner for it to stop producing more units.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### spawning_radius

How far from the spawner can the units be spawned.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### spawning_spacing

What spaces should be between the spawned units.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Spawner

### radius

The radius of this entity prototype. The radius is defined as half the distance between the top left corner and bottom right corner of the collision box.

**Read type:** `double`

### cliff_explosive_prototype

The item prototype name used to destroy this cliff.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** Cliff

### rocket_entity_prototype

The rocket entity prototype associated with this rocket silo prototype.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

**Subclasses:** RocketSilo

### has_belt_immunity

Whether this unit, car, or character prototype has belt immunity.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Unit, Car, Character

### vision_distance

The vision distance of this unit prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit, SegmentedUnit

### absorptions_to_join_attack

A table of pollutions amounts that has to be absorbed by the unit's spawner before the unit will leave the spawner and attack the source of the pollution, indexed by the name of each absorbed pollution type.

**Read type:** Dictionary[`string`, `float`]

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### min_pursue_time

The minimum pursue time of this unit prototype.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### max_pursue_distance

The maximum pursue distance of this unit prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### radar_range

The radar range of this unit prototype.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### move_while_shooting

Whether this unit prototype can move while shooting.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Unit

### can_open_gates

Whether this unit prototype can open gates.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Unit

### affected_by_tiles

Whether this unit prototype is affected by tile walking speed modifiers.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Unit

### distraction_cooldown

The distraction cooldown of this unit prototype.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### spawning_time_modifier

The spawning time modifier of this unit prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, Unit

### alert_icon_shift

The alert icon shift of this entity prototype.

**Read type:** `Vector`

### alert_icon_scale

The alert icon scale of this entity prototype.

**Read type:** `float`

### lab_inputs

The item prototype names that are the inputs of this lab prototype.

**Read type:** Array[`string`]

**Optional:** Yes

**Subclasses:** Lab

### science_pack_drain_rate_percent

How much science pack durability is required to research one science point.

**Read type:** `uint8`

**Subclasses:** Lab

### effect_receiver

Effect receiver prototype of this crafting machine, lab, or mining drill.

**Read type:** `EffectReceiver`

**Optional:** Yes

**Subclasses:** CraftingMachine, Lab, MiningDrill

### allow_access_to_all_forces

Whether this market allows access to all forces or just friendly ones.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Market

### supports_direction

Whether this entity prototype could possibly ever be rotated.

**Read type:** `boolean`

### terrain_friction_modifier

The terrain friction modifier for this vehicle.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Vehicle

### allow_passengers

Whether this vehicle allows passengers.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Vehicle

### grid_prototype

The equipment grid prototype for this entity, if any.

**Read type:** `LuaEquipmentGridPrototype`

**Optional:** Yes

### remove_decoratives

Whether this entity should remove decoratives that collide with it when this entity is built.

**Read type:** `"automatic"` | `"true"` | `"false"`

### related_underground_belt

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

**Subclasses:** TransportBelt

### inserter_stack_size_bonus

The built-in stack size bonus of this inserter prototype.

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Inserter

### protected_from_tile_building

True if this entity prototype should be included during tile collision checks with [LuaTilePrototype::check_collision_with_entities](runtime:LuaTilePrototype::check_collision_with_entities) enabled.

**Read type:** `boolean`

### is_entity_with_owner

True if this is entity-with-owner

**Read type:** `boolean`

### is_military_target

True if this entity-with-owner is military target

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** EntityWithOwner

### allow_run_time_change_of_is_military_target

True if this entity-with-owner's is_military_target can be changed run-time (on the entity, not on the prototype itself)

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** EntityWithOwner

### logistic_parameters

The logistic parameters for this roboport.

**Read type:** Table (see below for parameters)

**Optional:** Yes

**Subclasses:** Roboport

### height

The height of this spider vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, SpiderVehicle

### torso_rotation_speed

The torso rotation speed of this spider vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, SpiderVehicle

### torso_bob_speed

The torso bob speed of this spider vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderUnit, SpiderVehicle

### automatic_weapon_cycling

Whether this spider vehicle prototype automatically cycles weapons.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** SpiderVehicle

### chain_shooting_cooldown_modifier

The chain shooting cooldown modifier of this spider vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SpiderVehicle

### spider_engine

**Read type:** `SpiderEngineSpecification`

**Optional:** Yes

**Subclasses:** SpiderVehicle, SpiderUnit

### chunk_exploration_radius

The chunk exploration radius of this vehicle prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Vehicle

### animation_speed_coefficient

The animation speed coefficient of this belt connectable prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** BeltConnectable

### manual_range_modifier

The manual range modifier for this artillery turret or wagon prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** ArtilleryWagon, ArtilleryTurret

### dying_speed

The dying time of this corpse prototype.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** Corpse

### active_energy_usage

The active energy usage of this rocket silo or combinator prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSilo, Combinator

### lamp_energy_usage

The lamp energy usage of this rocket silo prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RocketSilo

### crane_energy_usage

The crane energy usage of this agricultural tower prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AgriculturalTower

### use_exact_mode

Whether this logistic container prototype uses exact mode

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** LogisticContainer

### tile_width

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension)

**Read type:** `uint32`

### tile_height

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension)

**Read type:** `uint32`

### vertical_selection_shift

Vertical selection shift used by rolling stocks. It affects selection box vertical position but is also used to shift rolling stock graphics along the rails to fine tune train's look.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RollingStock

### spawn_decoration

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

**Subclasses:** Spawner, Turret

### spawn_decorations_on_expansion

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Spawner, Turret

### connection_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RollingStock

### joint_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RollingStock

### radius_visualisation_specification

**Read type:** `RadiusVisualisationSpecification`

**Optional:** Yes

### growth_ticks

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Plant

### harvest_emissions

A table of pollutants that this plant will release when it is harvested.

**Read type:** Dictionary[`string`, `double`]

**Optional:** Yes

**Subclasses:** Plant

### agricultural_tower_radius

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AgriculturalTower

### growth_area_radius

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AgriculturalTower

### growth_grid_tile_size

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AgriculturalTower

### vector_to_place_result

**Read type:** `Vector`

**Optional:** Yes

**Subclasses:** MiningDrill, CraftingMachine

### surface_conditions

The surface conditions required to build this entity.

**Read type:** Array[`SurfaceCondition`]

**Optional:** Yes

### heating_energy

The energy required to keep this entity from freezing. Zero energy means it doesn't freeze.

**Read type:** `double`

### auto_setup_collision_box

**Read type:** `boolean`

**Subclasses:** Corpse

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### rewire_neighbours_when_destroying

**Read type:** `boolean`

**Subclasses:** ElectricPole

### solar_panel_performance_at_day

**Read type:** `double`

**Subclasses:** SolarPanel

### solar_panel_performance_at_night

**Read type:** `double`

**Subclasses:** SolarPanel

### solar_panel_solar_coefficient_property

**Read type:** `LuaSurfacePropertyPrototype`

**Subclasses:** SolarPanel

### accepted_seeds

**Read type:** Array[`string`]

**Optional:** Yes

**Subclasses:** AgriculturalTower

### captured_spawner_entity

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

**Subclasses:** EnemySpawnerPrototype

### min_performance

**Read type:** `ThrusterPerformancePoint`

**Optional:** Yes

**Subclasses:** ThrusterPrototype

### max_performance

**Read type:** `ThrusterPerformancePoint`

**Optional:** Yes

**Subclasses:** ThrusterPrototype

### two_direction_only

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** FusionReactor

### perceived_performance

**Read type:** `PerceivedPerformance`

**Optional:** Yes

**Subclasses:** FusionReactor

### overkill_fraction

**Read type:** `float`

**Optional:** Yes

**Subclasses:** EntityWithHealth

### dying_explosion

**Read type:** Array[`ExplosionDefinition`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### dying_trigger_effect

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### damaged_trigger_effect

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### attack_reaction

**Read type:** Array[`AttackReactionItem`]

**Optional:** Yes

**Subclasses:** EntityWithHealth

### hide_resistances

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** EntityWithHealth

### random_corpse_variation

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** EntityWithHealth

### neighbour_connectable

**Read type:** `NeighbourConnectable`

**Optional:** Yes

**Subclasses:** FusionReactor

### tile_buildability_rules

**Read type:** Array[`TileBuildabilityRule`]

**Optional:** Yes

### support_range

**Read type:** `float`

**Optional:** Yes

**Subclasses:** RailSupport, RailRamp

### territory_radius

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### enraged_duration

**Read type:** `MapTick`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### patrolling_speed

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### investigating_speed

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### attacking_speed

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### enraged_speed

**Read type:** `double`

**Subclasses:** SegmentedUnit

### acceleration_rate

**Read type:** `double`

**Subclasses:** SegmentedUnit

### turn_radius

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### patrolling_turn_radius

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### turn_smoothing

**Read type:** `double`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### ticks_per_scan

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### segment_engine

**Read type:** `SegmentEngineSpecification`

**Optional:** Yes

**Subclasses:** SegmentedUnit

### running_speed

The movement speed of this character prototype.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### maximum_corner_sliding_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### build_distance

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### drop_item_distance

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### reach_distance

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### reach_resource_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### item_pickup_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### loot_pickup_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### enter_vehicle_distance

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Character

### ticks_to_keep_gun

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### ticks_to_keep_aiming_direction

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### ticks_to_stay_in_combat

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### respawn_time

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** Character

### damage_hit_tint

**Read type:** `Color`

**Optional:** Yes

**Subclasses:** Character

### character_corpse

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

**Subclasses:** Character

### arm_inventory_size_quality_increase

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### inventory_size_quality_increase

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### passive_energy_usage

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_energy_usage

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_slow_energy_usage

**Read type:** `double`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### energy_usage_quality_scaling

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_count_base

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_count_quality_scaling

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### head_collection_radius

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### collection_box_offset

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### deposit_radius

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_speed_base

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_speed_quality_scaling

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_angular_speed_cap_base

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_angular_speed_cap_quality_scaling

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### tether_size

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### unpowered_arm_speed_scale

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### minimal_arm_swing_segment_retraction

**Read type:** `uint32`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### held_items_offset

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### held_items_spread

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### held_items_display_count

**Read type:** `uint8`

**Optional:** Yes

**Subclasses:** AsteroidCollector

### arm_color_gradient

**Read type:** Array[`Color`]

**Optional:** Yes

**Subclasses:** AsteroidCollector

### fluid_buffer_size

**Read type:** `FluidAmount`

**Optional:** Yes

**Subclasses:** FluidTurret

### activation_buffer_ratio

**Read type:** `FluidAmount`

**Optional:** Yes

**Subclasses:** FluidTurret

### fluid_buffer_input_flow

**Read type:** `FluidAmount`

**Optional:** Yes

**Subclasses:** FluidTurret

### range_from_player

**Read type:** `double`

**Optional:** Yes

**Subclasses:** CombatRobot

### combat_robot_friction

**Read type:** `double`

**Optional:** Yes

**Subclasses:** CombatRobot

### destroy_action

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

**Subclasses:** CombatRobot

### follows_player

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** CombatRobot

### strike_effect

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

**Subclasses:** Lightning

### attractor_hit_effect

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

**Subclasses:** Lightning

### damage

When lightning strikes something that is not a lightning attractor, this damage is applied to the target.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Lightning

### energy

When lightning hits a lightning attractor this amount of energy is transferred to the lightning attractor.

**Read type:** `double`

**Optional:** Yes

**Subclasses:** Lightning

### connection_category

**Read type:** Array[`string`]

**Subclasses:** FluidWagon

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### has_flag

Test whether this entity prototype has a certain flag set.

**Parameters:**

- `flag` `EntityPrototypeFlag` - The flag to test.

**Returns:**

- `boolean` - `true` if this prototype has the given flag set.

### get_inventory_size

Gets the base size of the given inventory on this entity or `nil` if the given inventory doesn't exist.

**Parameters:**

- `index` `defines.inventory`
- `quality` `QualityID` *(optional)* - Defaults to `"normal"`.

**Returns:**

- `uint32` *(optional)*

### get_crafting_speed

The crafting speed of this crafting-machine or character.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_supply_area_distance

The supply area of this electric pole or beacon prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_max_wire_distance

The maximum wire distance for this entity. 0 if the entity doesn't support wires.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_max_circuit_wire_distance

The maximum circuit wire distance for this entity. 0 if the entity doesn't support circuit wires.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_max_energy_usage

The theoretical maximum energy usage for this entity.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_max_energy_production

The theoretical maximum energy production for this entity.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_max_energy

The max energy for this flying robot prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_inserter_extension_speed

The extension speed of this inserter.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_inserter_rotation_speed

The rotation speed of this inserter.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_researching_speed

The base researching speed of this lab prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_max_distance_of_sector_revealed

The radius of the area this radar can chart, in chunks.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `uint32` *(optional)*

### get_max_distance_of_nearby_sector_revealed

The radius of the area constantly revealed by this radar, or cargo landing pad, in chunks.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `uint32` *(optional)*

### get_max_health

Max health of this entity. Will be `0` if this is not an entity with health.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `float`

### get_fluid_usage_per_tick

The fluid usage of this generator, fusion generator or fusion reactor prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_max_power_output

The maximum power output of this burner generator or generator prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_pumping_speed

The pumping speed of this offshore pump or normal pump.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_valve_flow_rate

The maximum flow rate through this valve.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_mining_drill_radius

The mining radius of this mining drill prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_fluid_capacity

Gets the fluid capacity of this entity or 0 if this entity doesn't support fluids.

Crafting machines will report 0 due to their fluid capacity being whatever a given recipe needs.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_attraction_range_elongation

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

### get_energy_distribution_efficiency

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

