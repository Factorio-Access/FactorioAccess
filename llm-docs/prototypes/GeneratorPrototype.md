# GeneratorPrototype

An entity that produces power from fluids, for example a [steam engine](https://wiki.factorio.com/Steam_engine).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `ElectricEnergySource`



#### fluid_box

**Type:** `FluidBox`

This must have a filter if `max_power_output` is not defined.

#### fluid_usage_per_tick

**Type:** `FluidAmount`

The number of fluid units the generator uses per tick.

#### maximum_temperature

**Type:** `float`

The maximum temperature to which the efficiency can increase. At this temperature the generator will run at 100% efficiency. Note: Higher temperature fluid can still be consumed.

Used to calculate the `max_power_output` if it is not defined and `burns_fluid` is false. Then, the max power output is `(min(fluid_max_temp, maximum_temperature) - fluid_default_temp) × fluid_usage_per_tick × fluid_heat_capacity × effectivity`, the fluid is the filter specified on the `fluid_box`.

### Optional Properties

#### burns_fluid

**Type:** `boolean`

If set to true, the available power output is based on the [FluidPrototype::fuel_value](prototype:FluidPrototype::fuel_value). Otherwise, the available power output will be based on the fluid temperature.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### destroy_non_fuel_fluid

**Type:** `boolean`

This property is used when `burns_fluid` is true and the fluid has a [fuel_value](prototype:FluidPrototype::fuel_value) of 0.

This property is also used when `burns_fluid` is false and the fluid is at default temperature.

In these cases, this property determines whether the fluid should be destroyed, meaning that the fluid is consumed at the rate of `fluid_usage_per_tick`, without producing any power.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### effectivity

**Type:** `double`

How much energy the generator produces compared to how much energy it consumes. For example, an effectivity of 0.5 means that half of the consumed energy is output as power.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### horizontal_animation

**Type:** `Animation`



#### horizontal_frozen_patch

**Type:** `Sprite`



#### max_power_output

**Type:** `Energy`

The power production of the generator is capped to this value. This is also the value that is shown as the maximum power output in the tooltip of the generator.

`fluid_box` must have a filter if this is not defined.

#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed and working sound.

#### scale_fluid_usage

**Type:** `boolean`

Scales the generator's fluid usage to its maximum power output.

Setting this to true prevents the generator from overconsuming fluid, for example when higher than`maximum_temperature` fluid is fed to the generator.

If scale_fluid_usage is false, the generator consumes the full `fluid_usage_per_tick` and any of the extra energy in the fluid (in the form of higher temperature) is wasted. The [steam engine](https://wiki.factorio.com/Steam_engine) exhibits this behavior when fed steam from [heat exchangers](https://wiki.factorio.com/Heat_exchanger).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### smoke

**Type:** ``SmokeSource`[]`



#### vertical_animation

**Type:** `Animation`



#### vertical_frozen_patch

**Type:** `Sprite`



