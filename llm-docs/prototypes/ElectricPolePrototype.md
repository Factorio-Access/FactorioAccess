# ElectricPolePrototype

An electric pole - part of the [electric system](https://wiki.factorio.com/Electric_system).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### connection_points

**Type:** ``WireConnectionPoint`[]`



#### supply_area_distance

**Type:** `double`

The "radius" of this pole's supply area. Corresponds to *half* of the "supply area" in the item tooltip. If this is 3.5, the pole will have a 7x7 supply area.

Max value is 64.

### Optional Properties

#### active_picture

**Type:** `Sprite`

Drawn above the `pictures` when the electric pole is connected to an electric network.

#### auto_connect_up_to_n_wires

**Type:** `uint8`

`0` means disable auto-connect.

**Default:** `{'complex_type': 'literal', 'value': 5}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### light

**Type:** `LightDefinition`

Drawn when the electric pole is connected to an electric network.

#### maximum_wire_distance

**Type:** `double`

The maximum distance between this pole and any other connected pole - if two poles are farther apart than this, they cannot be connected together directly. Corresponds to "wire reach" in the item tooltip.

Max value is 64.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### pictures

**Type:** `RotatedSprite`



#### radius_visualisation_picture

**Type:** `Sprite`



#### rewire_neighbours_when_destroying

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### track_coverage_during_build_by_moving

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

