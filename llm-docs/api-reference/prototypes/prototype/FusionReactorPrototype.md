# FusionReactorPrototype

Fusion reactor. Consumes fluid, fuel and additional energy to produce other fluid. Kind of advanced boiler. Can also have neighbour bonus.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `fusion-reactor`

## Properties

### energy_source

First energy source for the process: provides energy

**Type:** `ElectricEnergySource`

**Required:** Yes

### burner

Second energy source for the process: provides fuel

**Type:** `BurnerEnergySource`

**Required:** Yes

### graphics_set

**Type:** `FusionReactorGraphicsSet`

**Required:** Yes

### input_fluid_box

The input fluid box.

[filter](prototype:FluidBox::filter) is mandatory.

**Type:** `FluidBox`

**Required:** Yes

### output_fluid_box

The output fluid box.

[filter](prototype:FluidBox::filter) is mandatory.

**Type:** `FluidBox`

**Required:** Yes

### neighbour_connectable

Defines connection points to neighbours used to compute neighbour bonus.

**Type:** `NeighbourConnectable`

**Optional:** Yes

### two_direction_only

If set to true, only North and East direction will be buildable.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### neighbour_bonus

**Type:** `float`

**Optional:** Yes

**Default:** 1

### power_input

Power input consumed from first energy source at full performance.

Cannot be negative.

**Type:** `Energy`

**Required:** Yes

### max_fluid_usage

Maximum amount of fluid converted from `input_fluid_box` to `output_fluid_box` within a single tick.

Must be positive.

**Type:** `FluidAmount`

**Required:** Yes

### target_temperature

The temperature of the fluid to output. If not defined, the default temperature of the output fluid will be used.

**Type:** `float`

**Optional:** Yes

### perceived_performance

Affects working sound.

**Type:** `PerceivedPerformance`

**Optional:** Yes

