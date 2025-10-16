# CombinatorPrototype

Abstract base type for decider and arithmetic combinators.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### energy_source

Defines how this combinator gets energy. The emissions set on the energy source are ignored so combinators cannot produce pollution.

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

### active_energy_usage

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
active_energy_usage = "1kW"
```

### sprites

**Type:** `Sprite4Way`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite4Way`

**Optional:** Yes

### activity_led_sprites

**Type:** `Sprite4Way`

**Optional:** Yes

### input_connection_bounding_box

**Type:** `BoundingBox`

**Required:** Yes

### output_connection_bounding_box

**Type:** `BoundingBox`

**Required:** Yes

### activity_led_light_offsets

**Type:** (`Vector`, `Vector`, `Vector`, `Vector`)

**Required:** Yes

### screen_light_offsets

**Type:** (`Vector`, `Vector`, `Vector`, `Vector`)

**Required:** Yes

### input_connection_points

**Type:** (`WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`)

**Required:** Yes

### output_connection_points

**Type:** (`WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`)

**Required:** Yes

### activity_led_light

**Type:** `LightDefinition`

**Optional:** Yes

### screen_light

**Type:** `LightDefinition`

**Optional:** Yes

### activity_led_hold_time

**Type:** `uint8`

**Optional:** Yes

**Default:** 5

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

### emissions_per_second

Emissions cannot be larger than zero, combinators cannot produce pollution.

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

**Overrides parent:** Yes

