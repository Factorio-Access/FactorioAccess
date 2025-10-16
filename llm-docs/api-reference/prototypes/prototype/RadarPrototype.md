# RadarPrototype

A [radar](https://wiki.factorio.com/Radar).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `radar`

## Properties

### energy_usage

The amount of energy this radar uses.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "300kW"
```

### energy_per_sector

The amount of energy it takes to scan a sector. This value doesn't have any effect on nearby scanning.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_per_sector = "10MJ"
```

### energy_per_nearby_scan

The amount of energy the radar has to consume for nearby scan to be performed. This value doesn't have any effect on sector scanning.

Performance warning: nearby scan causes re-charting of many chunks, which is expensive operation. If you want to make a radar that updates map more in real time, you should keep its range low. If you are making radar with high range, you should set this value such that nearby scan is performed once a second or so. For example if you set `energy_usage` to 100kW, setting `energy_per_nearby_scan` to 100kJ will cause nearby scan to happen once per second.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_per_nearby_scan = "250kJ"
```

### energy_source

The energy source for this radar.

**Type:** `EnergySource`

**Required:** Yes

### pictures

**Type:** `RotatedSprite`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### max_distance_of_sector_revealed

The radius of the area this radar can chart, in chunks.

**Type:** `uint32`

**Required:** Yes

### max_distance_of_nearby_sector_revealed

The radius of the area constantly revealed by this radar, in chunks.

**Type:** `uint32`

**Required:** Yes

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

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

### radius_minimap_visualisation_color

**Type:** `Color`

**Optional:** Yes

### rotation_speed

**Type:** `double`

**Optional:** Yes

**Default:** 0.01

### connects_to_other_radars

If set to true, radars on the same surface will connect to other radars on the same surface using hidden wires with [radar](runtime:defines.wire_origin.radars) origin.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### reset_orientation_when_frozen

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### energy_fraction_to_connect

Must be between 0 and 1. Must be larger than or equal to `energy_fraction_to_disconnect`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.9

### energy_fraction_to_disconnect

Must be between 0 and 1. Must be less than or equal to `energy_fraction_to_connect`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

