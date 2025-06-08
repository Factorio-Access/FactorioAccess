# OffshorePumpPrototype

An [offshore pump](https://wiki.factorio.com/Offshore_pump).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `EnergySource`

Defines how the offshore pump is powered.

When using an electric energy source and `drain` is not specified, it will be set to `energy_usage ÷ 30` automatically.

#### energy_usage

**Type:** `Energy`

Sets how much energy this offshore pump consumes. Energy usage has to be positive.

#### fluid_box

**Type:** `FluidBox`



#### fluid_source_offset

**Type:** `Vector`



#### pumping_speed

**Type:** `FluidAmount`

How many units of fluid are produced per tick. Must be > 0.

### Optional Properties

#### always_draw_fluid

**Type:** `boolean`

If false, the offshore pump will not show fluid present (visually) before there is an output connected. The pump will also animate yet not show fluid when the fluid is 100% extracted (e.g. such as with a pump).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### circuit_connector

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### graphics_set

**Type:** `OffshorePumpGraphicsSet`



#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed.

#### remove_on_tile_collision

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

