# PumpPrototype

The pump is used to transfer fluids between tanks, fluid wagons and pipes.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `EnergySource`

The type of energy the pump uses.

#### energy_usage

**Type:** `Energy`

The amount of energy the pump uses.

#### fluid_box

**Type:** `FluidBox`

The area of the entity where fluid travels.

#### pumping_speed

**Type:** `FluidAmount`

The amount of fluid this pump transfers per tick.

### Optional Properties

#### animations

**Type:** `Animation4Way`

The animation for the pump.

#### circuit_connector

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### flow_scaling

**Type:** `boolean`

When true, pump will reduce pumping speed based on fullness of the input fluid segment.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### fluid_animation

**Type:** `Animation4Way`



#### fluid_wagon_connector_alignment_tolerance

**Type:** `double`



**Default:** `2 / 32.0`

#### fluid_wagon_connector_frame_count

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### fluid_wagon_connector_graphics

**Type:** `FluidWagonConnectorGraphics`



#### fluid_wagon_connector_speed

**Type:** `double`



**Default:** `1 / 64.0`

#### frozen_patch

**Type:** `Sprite4Way`



#### glass_pictures

**Type:** `Sprite4Way`



