# PumpPrototype

The pump is used to transfer fluids between tanks, fluid wagons and pipes.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `pump`

## Properties

### fluid_box

The area of the entity where fluid travels.

**Type:** `FluidBox`

**Required:** Yes

### energy_source

The type of energy the pump uses.

**Type:** `EnergySource`

**Required:** Yes

### energy_usage

The amount of energy the pump uses.

**Type:** `Energy`

**Required:** Yes

### pumping_speed

The amount of fluid this pump transfers per tick.

**Type:** `FluidAmount`

**Required:** Yes

### animations

The animation for the pump.

**Type:** `Animation4Way`

**Optional:** Yes

### fluid_wagon_connector_speed

**Type:** `double`

**Optional:** Yes

**Default:** "1 / 64.0"

### fluid_wagon_connector_alignment_tolerance

**Type:** `double`

**Optional:** Yes

**Default:** "2 / 32.0"

### fluid_wagon_connector_frame_count

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### flow_scaling

When true, pump will reduce pumping speed based on fullness of the input fluid segment.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### fluid_animation

**Type:** `Animation4Way`

**Optional:** Yes

### glass_pictures

**Type:** `Sprite4Way`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite4Way`

**Optional:** Yes

### circuit_wire_max_distance

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

### fluid_wagon_connector_graphics

**Type:** `FluidWagonConnectorGraphics`

**Optional:** Yes

