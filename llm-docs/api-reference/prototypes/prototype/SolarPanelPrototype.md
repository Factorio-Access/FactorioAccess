# SolarPanelPrototype

A [solar panel](https://wiki.factorio.com/Solar_panel).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `solar-panel`

## Properties

### energy_source

Sets how this solar panel connects to the energy network. The most relevant property seems to be the output_priority.

**Type:** `ElectricEnergySource`

**Required:** Yes

### picture

The picture displayed for this solar panel.

**Type:** `SpriteVariations`

**Optional:** Yes

### production

The maximum amount of power this solar panel can produce.

**Type:** `Energy`

**Required:** Yes

### overlay

Overlay has to be empty or have same number of variations as `picture`.

**Type:** `SpriteVariations`

**Optional:** Yes

### performance_at_day

**Type:** `double`

**Optional:** Yes

**Default:** 1

### performance_at_night

**Type:** `double`

**Optional:** Yes

**Default:** 0

### solar_coefficient_property

Surface property must have a positive [default value](prototype:SurfacePropertyPrototype::default_value). When [SolarPanelPrototype::solar_coefficient_property](prototype:SolarPanelPrototype::solar_coefficient_property) is set to point at a different surface property than "solar-power", then [LuaSurface::solar_power_multiplier](runtime:LuaSurface::solar_power_multiplier) and [SpaceLocationPrototype::solar_power_in_space](prototype:SpaceLocationPrototype::solar_power_in_space) will be ignored as the solar panel power output will be only affected by value of this surface property set on the surface using [PlanetPrototype::surface_properties](prototype:PlanetPrototype::surface_properties) or [LuaSurface::set_property](runtime:LuaSurface::set_property).

**Type:** `SurfacePropertyID`

**Optional:** Yes

**Default:** "solar-power"

