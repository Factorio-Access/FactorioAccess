# AccumulatorPrototype

Entity with energy source with specialised animation for charging/discharging. Used for the [accumulator](https://wiki.factorio.com/Accumulator) entity.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `ElectricEnergySource`

The capacity of the energy source buffer specifies the capacity of the accumulator.

### Optional Properties

#### chargable_graphics

**Type:** `ChargableGraphics`



#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_output_signal

**Type:** `SignalIDConnector`

The name of the signal that is the default for when an accumulator is connected to the circuit network.

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

