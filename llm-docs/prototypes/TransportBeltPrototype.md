# TransportBeltPrototype

A [transport belt](https://wiki.factorio.com/Transport_belt).

**Parent:** `TransportBeltConnectablePrototype`

## Properties

### Optional Properties

#### belt_animation_set

**Type:** `TransportBeltAnimationSetWithCorners`



#### circuit_connector

**Type:** ``CircuitConnectorDefinition`[]`

Set of 7 [circuit connector definitions](prototype:CircuitConnectorDefinition) in order: X, H, V, SE, SW, NE and NW.

#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### connector_frame_sprites

**Type:** `TransportBeltConnectorFrame`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### related_underground_belt

**Type:** `EntityID`

The name of the [UndergroundBeltPrototype](prototype:UndergroundBeltPrototype) which is used in quick-replace fashion when the smart belt dragging behavior is triggered.

