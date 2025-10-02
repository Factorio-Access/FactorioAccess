# OffshorePumpPrototype

An [offshore pump](https://wiki.factorio.com/Offshore_pump).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `offshore-pump`

## Properties

### fluid_box

**Type:** `FluidBox`

**Required:** Yes

### pumping_speed

How many units of fluid are produced per tick. Must be > 0.

**Type:** `FluidAmount`

**Required:** Yes

### fluid_source_offset

**Type:** `Vector`

**Required:** Yes

### perceived_performance

Affects animation speed.

**Type:** `PerceivedPerformance`

**Optional:** Yes

### graphics_set

**Type:** `OffshorePumpGraphicsSet`

**Optional:** Yes

### energy_source

Defines how the offshore pump is powered.

When using an electric energy source and `drain` is not specified, it will be set to `energy_usage ÷ 30` automatically.

**Type:** `EnergySource`

**Required:** Yes

### energy_usage

Sets how much energy this offshore pump consumes. Energy usage has to be positive.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "60kW"
```

### remove_on_tile_collision

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### always_draw_fluid

If false, the offshore pump will not show fluid present (visually) before there is an output connected. The pump will also animate yet not show fluid when the fluid is 100% extracted (e.g. such as with a pump).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

