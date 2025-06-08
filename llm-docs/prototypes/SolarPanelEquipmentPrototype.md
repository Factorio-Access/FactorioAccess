# SolarPanelEquipmentPrototype

A [portable solar panel](https://wiki.factorio.com/Portable_solar_panel).

**Parent:** `EquipmentPrototype`

## Properties

### Mandatory Properties

#### power

**Type:** `Energy`

How much power should be provided.

### Optional Properties

#### performance_at_day

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### performance_at_night

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### solar_coefficient_property

**Type:** `SurfacePropertyID`

Surface property must have a positive [default value](prototype:SurfacePropertyPrototype::default_value). When [SolarPanelEquipmentPrototype::solar_coefficient_property](prototype:SolarPanelEquipmentPrototype::solar_coefficient_property) is set to point at a different surface property than "solar-power", then [LuaSurface::solar_power_multiplier](runtime:LuaSurface::solar_power_multiplier) and [SpaceLocationPrototype::solar_power_in_space](prototype:SpaceLocationPrototype::solar_power_in_space) will be ignored as the solar panel power output will be only affected by value of this surface property set on the surface using [PlanetPrototype::surface_properties](prototype:PlanetPrototype::surface_properties) or [LuaSurface::set_property](runtime:LuaSurface::set_property).

Due to equipment grid overall description, when solar_coefficient_property is not solar-power, a different locale will be used to show total energy production of solar panels: `description.solar-panel-power-X` where X is the surface property name.

**Default:** `{'complex_type': 'literal', 'value': 'solar-power'}`

