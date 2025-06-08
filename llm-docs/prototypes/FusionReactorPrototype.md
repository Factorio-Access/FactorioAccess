# FusionReactorPrototype

Fusion reactor. Consumes fluid, fuel and additional energy to produce other fluid. Kind of advanced boiler. Can also have neighbour bonus.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### burner

**Type:** `BurnerEnergySource`

Second energy source for the process: provides fuel

#### energy_source

**Type:** `ElectricEnergySource`

First energy source for the process: provides energy

#### graphics_set

**Type:** `FusionReactorGraphicsSet`



#### input_fluid_box

**Type:** `FluidBox`

The input fluid box.

[filter](prototype:FluidBox::filter) is mandatory.

#### max_fluid_usage

**Type:** `FluidAmount`

Maximum amount of fluid converted from `input_fluid_box` to `output_fluid_box` within a single tick.

Must be positive.

#### output_fluid_box

**Type:** `FluidBox`

The output fluid box.

[filter](prototype:FluidBox::filter) is mandatory.

#### power_input

**Type:** `Energy`

Power input consumed from first energy source at full performance.

Cannot be negative.

### Optional Properties

#### neighbour_bonus

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### neighbour_connectable

**Type:** `NeighbourConnectable`

Defines connection points to neighbours used to compute neighbour bonus.

#### perceived_performance

**Type:** `PerceivedPerformance`

Affects working sound.

#### target_temperature

**Type:** `float`

The temperature of the fluid to output. If not defined, the default temperature of the output fluid will be used.

#### two_direction_only

**Type:** `boolean`

If set to true, only North and East direction will be buildable.

**Default:** `{'complex_type': 'literal', 'value': False}`

