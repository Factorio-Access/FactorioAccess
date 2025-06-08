# SolarPanelPrototype

A [solar panel](https://wiki.factorio.com/Solar_panel).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `ElectricEnergySource`

Sets how this solar panel connects to the energy network. The most relevant property seems to be the output_priority.

#### production

**Type:** `Energy`

The maximum amount of power this solar panel can produce.

### Optional Properties

#### overlay

**Type:** `SpriteVariations`

Overlay has to be empty or have same number of variations as `picture`.

#### performance_at_day

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### performance_at_night

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### picture

**Type:** `SpriteVariations`

The picture displayed for this solar panel.

#### solar_coefficient_property

**Type:** `SurfacePropertyID`

Surface property must have a positive [default value](prototype:SurfacePropertyPrototype::default_value). When [SolarPanelPrototype::solar_coefficient_property](prototype:SolarPanelPrototype::solar_coefficient_property) is set to point at a different surface property than "solar-power", then [LuaSurface::solar_power_multiplier](runtime:LuaSurface::solar_power_multiplier) and [SpaceLocationPrototype::solar_power_in_space](prototype:SpaceLocationPrototype::solar_power_in_space) will be ignored as the solar panel power output will be only affected by value of this surface property set on the surface using [PlanetPrototype::surface_properties](prototype:PlanetPrototype::surface_properties) or [LuaSurface::set_property](runtime:LuaSurface::set_property).

**Default:** `{'complex_type': 'literal', 'value': 'solar-power'}`

