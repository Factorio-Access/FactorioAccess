# FusionGeneratorPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `fusion-generator`

## Properties

### energy_source

`output_flow_limit` is mandatory and must be positive.

**Type:** `ElectricEnergySource`

**Required:** Yes

### graphics_set

**Type:** `FusionGeneratorGraphicsSet`

**Optional:** Yes

### input_fluid_box

[filter](prototype:FluidBox::filter) is mandatory.

**Type:** `FluidBox`

**Required:** Yes

### output_fluid_box

[filter](prototype:FluidBox::filter) is mandatory.

**Type:** `FluidBox`

**Required:** Yes

### max_fluid_usage

Must be positive.

**Type:** `FluidAmount`

**Required:** Yes

### perceived_performance

Affects animation speed and working sound.

**Type:** `PerceivedPerformance`

**Optional:** Yes

