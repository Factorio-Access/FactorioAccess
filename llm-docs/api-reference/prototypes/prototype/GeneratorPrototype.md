# GeneratorPrototype

An entity that produces power from fluids, for example a [steam engine](https://wiki.factorio.com/Steam_engine).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `generator`

## Properties

### energy_source

**Type:** `ElectricEnergySource`

**Required:** Yes

### fluid_box

This must have a filter if `max_power_output` is not defined.

**Type:** `FluidBox`

**Required:** Yes

### horizontal_animation

**Type:** `Animation`

**Optional:** Yes

### vertical_animation

**Type:** `Animation`

**Optional:** Yes

### horizontal_frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### vertical_frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### effectivity

How much energy the generator produces compared to how much energy it consumes. For example, an effectivity of 0.5 means that half of the consumed energy is output as power.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### fluid_usage_per_tick

The number of fluid units the generator uses per tick.

**Type:** `FluidAmount`

**Required:** Yes

### maximum_temperature

The maximum temperature to which the efficiency can increase. At this temperature the generator will run at 100% efficiency. Note: Higher temperature fluid can still be consumed.

Used to calculate the `max_power_output` if it is not defined and `burns_fluid` is false. Then, the max power output is `(min(fluid_max_temp, maximum_temperature) - fluid_default_temp) × fluid_usage_per_tick × fluid_heat_capacity × effectivity`, the fluid is the filter specified on the `fluid_box`.

**Type:** `float`

**Required:** Yes

### smoke

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### burns_fluid

If set to true, the available power output is based on the [FluidPrototype::fuel_value](prototype:FluidPrototype::fuel_value). Otherwise, the available power output will be based on the fluid temperature.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scale_fluid_usage

Scales the generator's fluid usage to its maximum power output.

Setting this to true prevents the generator from overconsuming fluid, for example when higher than`maximum_temperature` fluid is fed to the generator.

If scale_fluid_usage is false, the generator consumes the full `fluid_usage_per_tick` and any of the extra energy in the fluid (in the form of higher temperature) is wasted. The [steam engine](https://wiki.factorio.com/Steam_engine) exhibits this behavior when fed steam from [heat exchangers](https://wiki.factorio.com/Heat_exchanger).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### destroy_non_fuel_fluid

This property is used when `burns_fluid` is true and the fluid has a [fuel_value](prototype:FluidPrototype::fuel_value) of 0.

This property is also used when `burns_fluid` is false and the fluid is at default temperature.

In these cases, this property determines whether the fluid should be destroyed, meaning that the fluid is consumed at the rate of `fluid_usage_per_tick`, without producing any power.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### perceived_performance

Affects animation speed and working sound.

**Type:** `PerceivedPerformance`

**Optional:** Yes

### max_power_output

The power production of the generator is capped to this value. This is also the value that is shown as the maximum power output in the tooltip of the generator.

`fluid_box` must have a filter if this is not defined.

**Type:** `Energy`

**Optional:** Yes

