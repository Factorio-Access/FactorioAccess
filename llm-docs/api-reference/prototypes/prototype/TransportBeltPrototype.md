# TransportBeltPrototype

A [transport belt](https://wiki.factorio.com/Transport_belt).

**Parent:** [TransportBeltConnectablePrototype](TransportBeltConnectablePrototype.md)
**Type name:** `transport-belt`

## Properties

### connector_frame_sprites

**Type:** `TransportBeltConnectorFrame`

**Optional:** Yes

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

Set of 7 [circuit connector definitions](prototype:CircuitConnectorDefinition) in order: X, H, V, SE, SW, NE and NW.

**Type:** Array[`CircuitConnectorDefinition`]

**Optional:** Yes

### belt_animation_set

**Type:** `TransportBeltAnimationSetWithCorners`

**Optional:** Yes

**Overrides parent:** Yes

### related_underground_belt

The name of the [UndergroundBeltPrototype](prototype:UndergroundBeltPrototype) which is used in quick-replace fashion when the smart belt dragging behavior is triggered.

**Type:** `EntityID`

**Optional:** Yes

