# ElectricPolePrototype

An electric pole - part of the [electric system](https://wiki.factorio.com/Electric_system).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `electric-pole`

## Properties

### pictures

**Type:** `RotatedSprite`

**Optional:** Yes

### supply_area_distance

The "radius" of this pole's supply area. Corresponds to *half* of the "supply area" in the item tooltip. If this is 3.5, the pole will have a 7x7 supply area.

Max value is 64.

**Type:** `double`

**Required:** Yes

### connection_points

**Type:** Array[`WireConnectionPoint`]

**Required:** Yes

### radius_visualisation_picture

**Type:** `Sprite`

**Optional:** Yes

### active_picture

Drawn above the `pictures` when the electric pole is connected to an electric network.

**Type:** `Sprite`

**Optional:** Yes

### maximum_wire_distance

The maximum distance between this pole and any other connected pole - if two poles are farther apart than this, they cannot be connected together directly. Corresponds to "wire reach" in the item tooltip.

Max value is 64.

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

### light

Drawn when the electric pole is connected to an electric network.

**Type:** `LightDefinition`

**Optional:** Yes

### track_coverage_during_build_by_moving

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### auto_connect_up_to_n_wires

`0` means disable auto-connect.

**Type:** `uint8`

**Optional:** Yes

**Default:** 5

### rewire_neighbours_when_destroying

**Type:** `boolean`

**Optional:** Yes

**Default:** True

