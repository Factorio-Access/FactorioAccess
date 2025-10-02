# ConstantCombinatorPrototype

A [constant combinator](https://wiki.factorio.com/Constant_combinator).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `constant-combinator`

## Properties

### sprites

**Type:** `Sprite4Way`

**Optional:** Yes

### activity_led_sprites

**Type:** `Sprite4Way`

**Optional:** Yes

### activity_led_light_offsets

**Type:** (`Vector`, `Vector`, `Vector`, `Vector`)

**Required:** Yes

### circuit_wire_connection_points

**Type:** (`WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`, `WireConnectionPoint`)

**Required:** Yes

### activity_led_light

**Type:** `LightDefinition`

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

### pulse_duration

When not zero, toggle entity will enable constant combinator for that amount of ticks and then turn it off.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

