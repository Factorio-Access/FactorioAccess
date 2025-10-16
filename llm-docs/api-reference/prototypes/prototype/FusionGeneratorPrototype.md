# FusionGeneratorPrototype

Consumes a fluid to generate electricity and create another fluid.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `fusion-generator`

## Properties

### energy_source

`output_flow_limit` is mandatory and must be positive. `output_flow_limit` is the maximum power output of the generator.

**Type:** `ElectricEnergySource`

**Required:** Yes

### graphics_set

**Type:** `FusionGeneratorGraphicsSet`

**Optional:** Yes

### input_fluid_box

[filter](prototype:FluidBox::filter) is mandatory. The temperature (or fuel value if `burns_fluid` is true) of this fluid is used to calculate the available power output.

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

### burns_fluid

If set to `true`, the available power output is based on the [FluidPrototype::fuel_value](prototype:FluidPrototype::fuel_value). Otherwise, the available power output will be based on the fluid temperature and [FluidPrototype::heat_capacity](prototype:FluidPrototype::heat_capacity): `energy = fluid_amount * fluid_temperature * fluid_heat_capacity * effectivity`

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### effectivity

`1` means 100% effectivity. Must be greater than `0`. Multiplier of the energy output.

**Type:** `double`

**Optional:** Yes

**Default:** 1

