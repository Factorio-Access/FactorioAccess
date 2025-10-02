# MiningDrillPrototype

A mining drill for automatically extracting resources from [resource entities](prototype:ResourceEntityPrototype). This prototype type is used by [burner mining drill](https://wiki.factorio.com/Burner_mining_drill), [electric mining drill](https://wiki.factorio.com/Electric_mining_drill) and [pumpjack](https://wiki.factorio.com/Pumpjack) in vanilla.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `mining-drill`

## Properties

### vector_to_place_result

The position where any item results are placed, when the mining drill is facing north (default direction). If the drill does not produce any solid items but uses a fluidbox output instead (e.g. pumpjacks), a vector of `{0,0}` disables the yellow arrow alt-mode indicator for the placed item location.

**Type:** `Vector`

**Required:** Yes

### resource_searching_radius

The distance from the centre of the mining drill to search for resources in.

This is 2.49 for electric mining drills (a 5x5 area) and 0.99 for burner mining drills (a 2x2 area). The drill searches resource outside its natural boundary box, which is 0.01 (the middle of the entity); making it 2.5 and 1.0 gives it another block radius.

**Type:** `double`

**Required:** Yes

### energy_usage

The amount of energy used by the drill while mining. Can't be less than or equal to 0.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "150kW"
```

### mining_speed

The speed of this drill.

**Type:** `double`

**Required:** Yes

### energy_source

The energy source of this mining drill.

**Type:** `EnergySource`

**Required:** Yes

### resource_categories

The names of the [ResourceCategory](prototype:ResourceCategory) that can be mined by this drill. For a list of built-in categories, see [here](https://wiki.factorio.com/Data.raw#resource-category).

Note: Categories containing resources which produce items, fluids, or items+fluids may be combined on the same entity, but may not work as expected. Examples: Miner does not rotate fluid-resulting resources until depletion. Fluid isn't output (fluid resource change and fluidbox matches previous fluid). Miner with no `vector_to_place_result` can't output an item result and halts.

**Type:** Array[`ResourceCategoryID`]

**Required:** Yes

### output_fluid_box

**Type:** `FluidBox`

**Optional:** Yes

### input_fluid_box

**Type:** `FluidBox`

**Optional:** Yes

### graphics_set

**Type:** `MiningDrillGraphicsSet`

**Optional:** Yes

### wet_mining_graphics_set

**Type:** `MiningDrillGraphicsSet`

**Optional:** Yes

### perceived_performance

Affects animation speed.

**Type:** `PerceivedPerformance`

**Optional:** Yes

### base_picture

Used by the [pumpjack](https://wiki.factorio.com/Pumpjack) to have a static 4 way sprite.

**Type:** `Sprite4Way`

**Optional:** Yes

### effect_receiver

**Type:** `EffectReceiver`

**Optional:** Yes

### module_slots

The number of module slots in this machine.

**Type:** `ItemStackIndex`

**Optional:** Yes

### quality_affects_module_slots

If set, [QualityPrototype::mining_drill_module_slots_bonus](prototype:QualityPrototype::mining_drill_module_slots_bonus) will be added to module slots count.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allowed_effects

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this mining drill.

**Type:** `EffectTypeLimitation`

**Optional:** Yes

**Default:** "All effects are allowed"

### allowed_module_categories

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Type:** Array[`ModuleCategoryID`]

**Optional:** Yes

**Default:** "All module categories are allowed"

### radius_visualisation_picture

The sprite used to show the range of the mining drill.

**Type:** `Sprite`

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

### base_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### resource_drain_rate_percent

May not be `0` or larger than `100`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 100

### shuffle_resources_to_mine

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### drops_full_belt_stacks

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### uses_force_mining_productivity_bonus

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### quality_affects_mining_radius

If set, [QualityPrototype::mining_drill_mining_radius_bonus](prototype:QualityPrototype::mining_drill_mining_radius_bonus) will be added to resource_searching_radius.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### moving_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### drilling_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### drilling_sound_animation_start_frame

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### drilling_sound_animation_end_frame

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### monitor_visualization_tint

When this mining drill is connected to the circuit network, the resource that it is reading (either the entire resource patch, or the resource in the mining area of the drill, depending on circuit network setting), is tinted in this color when mousing over the mining drill.

**Type:** `Color`

**Optional:** Yes

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### filter_count

How many filters this mining drill has. Maximum count of filtered resources in a mining drill is 5.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

