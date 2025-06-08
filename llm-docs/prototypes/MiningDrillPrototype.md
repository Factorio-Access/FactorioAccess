# MiningDrillPrototype

A mining drill for automatically extracting resources from [resource entities](prototype:ResourceEntityPrototype). This prototype type is used by [burner mining drill](https://wiki.factorio.com/Burner_mining_drill), [electric mining drill](https://wiki.factorio.com/Electric_mining_drill) and [pumpjack](https://wiki.factorio.com/Pumpjack) in vanilla.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `EnergySource`

The energy source of this mining drill.

#### energy_usage

**Type:** `Energy`

The amount of energy used by the drill while mining. Can't be less than or equal to 0.

#### mining_speed

**Type:** `double`

The speed of this drill.

#### resource_categories

**Type:** ``ResourceCategoryID`[]`

The names of the [ResourceCategory](prototype:ResourceCategory) that can be mined by this drill. For a list of built-in categories, see [here](https://wiki.factorio.com/Data.raw#resource-category).

Note: Categories containing resources which produce items, fluids, or items+fluids may be combined on the same entity, but may not work as expected. Examples: Miner does not rotate fluid-resulting resources until depletion. Fluid isn't output (fluid resource change and fluidbox matches previous fluid). Miner with no `vector_to_place_result` can't output an item result and halts.

#### resource_searching_radius

**Type:** `double`

The distance from the centre of the mining drill to search for resources in.

This is 2.49 for electric mining drills (a 5x5 area) and 0.99 for burner mining drills (a 2x2 area). The drill searches resource outside its natural boundary box, which is 0.01 (the middle of the entity); making it 2.5 and 1.0 gives it another block radius.

#### vector_to_place_result

**Type:** `Vector`

The position where any item results are placed, when the mining drill is facing north (default direction). If the drill does not produce any solid items but uses a fluidbox output instead (e.g. pumpjacks), a vector of `{0,0}` disables the yellow arrow alt-mode indicator for the placed item location.

### Optional Properties

#### allowed_effects

**Type:** `EffectTypeLimitation`

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this mining drill.

**Default:** `All effects are allowed`

#### allowed_module_categories

**Type:** ``ModuleCategoryID`[]`

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Default:** `All module categories are allowed`

#### base_picture

**Type:** `Sprite4Way`

Used by the [pumpjack](https://wiki.factorio.com/Pumpjack) to have a static 4 way sprite.

#### base_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### circuit_connector

**Type:** `[]`



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

#### drilling_sound

**Type:** `InterruptibleSound`



#### drilling_sound_animation_end_frame

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### drilling_sound_animation_start_frame

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### drops_full_belt_stacks

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### effect_receiver

**Type:** `EffectReceiver`



#### filter_count

**Type:** `uint8`

How many filters this mining drill has. Maximum count of filtered resources in a mining drill is 5.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### graphics_set

**Type:** `MiningDrillGraphicsSet`



#### input_fluid_box

**Type:** `FluidBox`



#### module_slots

**Type:** `ItemStackIndex`

The number of module slots in this machine.

#### monitor_visualization_tint

**Type:** `Color`

When this mining drill is connected to the circuit network, the resource that it is reading (either the entire resource patch, or the resource in the mining area of the drill, depending on circuit network setting), is tinted in this color when mousing over the mining drill.

#### moving_sound

**Type:** `InterruptibleSound`



#### output_fluid_box

**Type:** `FluidBox`



#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed.

#### radius_visualisation_picture

**Type:** `Sprite`

The sprite used to show the range of the mining drill.

#### resource_drain_rate_percent

**Type:** `uint8`

May not be `0` or larger than `100`.

**Default:** `{'complex_type': 'literal', 'value': 100}`

#### shuffle_resources_to_mine

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### uses_force_mining_productivity_bonus

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### wet_mining_graphics_set

**Type:** `MiningDrillGraphicsSet`



