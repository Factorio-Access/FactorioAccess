# ProgrammableSpeakerPrototype

A [programmable speaker](https://wiki.factorio.com/Programmable_speaker).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `programmable-speaker`

## Properties

### energy_source

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

### energy_usage_per_tick

**Type:** `Energy`

**Required:** Yes

### sprite

**Type:** `Sprite`

**Optional:** Yes

### maximum_polyphony

**Type:** `uint32`

**Required:** Yes

### instruments

**Type:** Array[`ProgrammableSpeakerInstrument`]

**Required:** Yes

### audible_distance_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

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

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

