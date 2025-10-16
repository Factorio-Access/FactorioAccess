# FluidEnergySource

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"fluid"`

**Required:** Yes

### fluid_box

All standard fluid box configurations are acceptable, but the type must be `"input"` or `"input-output"` to function correctly. `scale_fluid_usage = true`, `fluid_usage_per_tick`, or a filter on the fluidbox must be set to be able to calculate the fluid usage of the energy source.

**Type:** `FluidBox`

**Required:** Yes

### smoke

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### light_flicker

**Type:** `LightFlickeringDefinition`

**Optional:** Yes

### effectivity

`1` means 100% effectivity. Must be greater than `0`. Multiplier of the energy output.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### burns_fluid

If set to `true`, the available power output is based on the [FluidPrototype::fuel_value](prototype:FluidPrototype::fuel_value). Otherwise, the available power output will be based on the fluid temperature and [FluidPrototype::heat_capacity](prototype:FluidPrototype::heat_capacity): `energy = fluid_amount * (fluid_temperature - fluid_default_temperature) * fluid_heat_capacity * effectivity`

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scale_fluid_usage

If set to `true`, the energy source will consume as much fluid as required to produce the desired power, otherwise it will consume as much as it is allowed to, wasting any excess.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### destroy_non_fuel_fluid

Property is only used when `burns_fluid` is `true` and the fluid has a [fuel_value](prototype:FluidPrototype::fuel_value) of `0`, or when `burns_fluid` is `false` and the fluid is at its `default_temperature`.

In those cases, this property determines whether the fluid should be destroyed, meaning that the fluid is consumed at the rate of `fluid_usage_per_tick`, without producing any power.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### fluid_usage_per_tick

The number of fluid units the energy source uses per tick. If used with `scale_fluid_usage`, this specifies the maximum. If this value is not set, `scale_energy_usage` is `false` and a fluid box filter is set, the game will attempt to calculate this value from the fluid box filter's fluid's `fuel_value` or `heat_capacity` and the entity's `energy_usage`. If `burns_fluid` is `false`, `maximum_temperature` will also be used. If the attempt of the game to calculate this value fails (`scale_energy_usage` is `false` and a fluid box filter is set), then `scale_energy_usage` will be forced to `true`, to prevent the energy source from being an infinite fluid sink. More context [on the forums](https://forums.factorio.com/90613).

**Type:** `FluidAmount`

**Optional:** Yes

**Default:** 0

### maximum_temperature

`0` means unlimited maximum temperature. If this is non-zero while `scale_fluid_usage` is `false` and `fluid_usage_per_tick` is not specified, the game will use this value to calculate `fluid_usage_per_tick`. To do that, the filter on the `fluid_box` must be set.

Only loaded if `burns_fluid` is `false`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

