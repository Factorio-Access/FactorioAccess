# BoilerPrototype

A [boiler](https://wiki.factorio.com/Boiler). It heats fluid and optionally outputs it as a different fluid.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `boiler`

## Properties

### pictures

**Type:** `BoilerPictureSet`

**Optional:** Yes

### energy_source

**Type:** `EnergySource`

**Required:** Yes

### fluid_box

The input fluid box.

If `mode` is `"heat-fluid-inside"`, the fluid is heated up directly in this fluidbox.

**Type:** `FluidBox`

**Required:** Yes

### output_fluid_box

The output fluid box.

If `mode` is `"output-to-separate-pipe"` and this has a [filter](prototype:FluidBox::filter), the heated input fluid is converted to the output fluid that is set in the filter. The conversion ratio is based on the heat capacity of the fluids: `output_fluid_amount = input_fluid_amount * (output_fluid_heat_capacity / input_fluid_heat_capacity)`

If `mode` is `"heat-fluid-inside"`, this fluidbox is unused.

**Type:** `FluidBox`

**Required:** Yes

### energy_consumption

**Type:** `Energy`

**Required:** Yes

### burning_cooldown

Controls for how many ticks the boiler will show the fire and fire_glow after the energy source runs out of energy.

Note that `fire` and `fire_glow` alpha is set to the light intensity of the energy source, so 0 light intensity means the fire is invisible. For burner energy sources, the light intensity will reach zero rather quickly after the boiler runs out of fuel, effectively capping the time that `fire` and `fire_glow` will be shown after the boiler runs out of fuel.

**Type:** `uint16`

**Required:** Yes

### target_temperature

Only loaded, and mandatory if `mode` is `"output-to-separate-pipe"`. This is the temperature that the input fluid must reach to be moved to the output fluid box.

**Type:** `float`

**Optional:** Yes

### fire_glow_flicker_enabled

If this is set to false, `fire_glow` alpha is always 1 instead of being controlled by the light intensity of the energy source.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### fire_flicker_enabled

If this is set to false, `fire` alpha is always 1 instead of being controlled by the light intensity of the energy source.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### mode

In the `"output-to-separate-pipe"` mode, fluid is transferred from the `fluid_box` to the `output_fluid_box` when enough energy is available to [heat](prototype:FluidPrototype::heat_capacity) the input fluid to the `target_temperature`. Setting a filter on the `output_fluid_box` means that instead of the heated input fluid getting moved to the output, it is converted to the filtered fluid in a ratio based on the heat capacity of the fluids: `output_fluid_amount = input_fluid_amount * (output_fluid_heat_capacity / input_fluid_heat_capacity)`

In the `"heat-fluid-inside"` mode, fluid in the `fluid_box` is continuously heated from the input temperature up to its [FluidPrototype::max_temperature](prototype:FluidPrototype::max_temperature).

**Type:** `"heat-fluid-inside"` | `"output-to-separate-pipe"`

**Optional:** Yes

**Default:** "heat-fluid-inside"

