# RadarPrototype

A [radar](https://wiki.factorio.com/Radar).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_per_nearby_scan

**Type:** `Energy`

The amount of energy the radar has to consume for nearby scan to be performed. This value doesn't have any effect on sector scanning.

Performance warning: nearby scan causes re-charting of many chunks, which is expensive operation. If you want to make a radar that updates map more in real time, you should keep its range low. If you are making radar with high range, you should set this value such that nearby scan is performed once a second or so. For example if you set `energy_usage` to 100kW, setting `energy_per_nearby_scan` to 100kJ will cause nearby scan to happen once per second.

#### energy_per_sector

**Type:** `Energy`

The amount of energy it takes to scan a sector. This value doesn't have any effect on nearby scanning.

#### energy_source

**Type:** `EnergySource`

The energy source for this radar.

#### energy_usage

**Type:** `Energy`

The amount of energy this radar uses.

#### max_distance_of_nearby_sector_revealed

**Type:** `uint32`

The radius of the area constantly revealed by this radar, in chunks.

#### max_distance_of_sector_revealed

**Type:** `uint32`

The radius of the area this radar can chart, in chunks.

### Optional Properties

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### connects_to_other_radars

**Type:** `boolean`

If set to true, radars on the same surface will connect to other radars on the same surface using hidden wires with [radar](runtime:defines.wire_origin.radars) origin.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### energy_fraction_to_connect

**Type:** `float`

Must be between 0 and 1. Must be larger than or equal to `energy_fraction_to_disconnect`.

**Default:** `{'complex_type': 'literal', 'value': 0.9}`

#### energy_fraction_to_disconnect

**Type:** `float`

Must be between 0 and 1. Must be less than or equal to `energy_fraction_to_connect`.

**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### frozen_patch

**Type:** `Sprite`



#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### pictures

**Type:** `RotatedSprite`



#### radius_minimap_visualisation_color

**Type:** `Color`



#### reset_orientation_when_frozen

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### rotation_speed

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.01}`

