# RoboportPrototype

A [roboport](https://wiki.factorio.com/Roboport).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `roboport`

## Properties

### energy_source

The roboport's energy source.

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

### energy_usage

The amount of energy the roboport uses when idle.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "50kW"
```

### recharge_minimum

Minimum charge that the roboport has to have after a blackout (0 charge/buffered energy) to begin working again. Additionally, freshly placed roboports will have their energy buffer filled with `0.25 × recharge_minimum` energy.

Must be larger than or equal to `energy_usage` otherwise during low power the roboport will toggle on and off every tick.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
recharge_minimum = "40MJ"
```

### robot_slots_count

The number of robot slots in the roboport.

**Type:** `ItemStackIndex`

**Required:** Yes

### material_slots_count

The number of repair pack slots in the roboport.

**Type:** `ItemStackIndex`

**Required:** Yes

### base

**Type:** `Sprite`

**Optional:** Yes

### base_patch

**Type:** `Sprite`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### base_animation

The animation played when the roboport is idle.

**Type:** `Animation`

**Optional:** Yes

### door_animation_up

**Type:** `Animation`

**Optional:** Yes

### door_animation_down

**Type:** `Animation`

**Optional:** Yes

### request_to_open_door_timeout

**Type:** `uint32`

**Required:** Yes

### radar_range

Defaults to the max of logistic range or construction range rounded up to chunks.

**Type:** `uint32`

**Optional:** Yes

### radar_visualisation_color

**Type:** `Color`

**Optional:** Yes

### recharging_animation

The animation played at each charging point when a robot is charging there.

**Type:** `Animation`

**Optional:** Yes

### spawn_and_station_height

Presumably states the height of the charging stations and thus an additive offset for the charging_offsets.

**Type:** `float`

**Required:** Yes

### charge_approach_distance

The distance (in tiles) from the roboport at which robots will wait to charge. Notably, if the robot is already in range, then it will simply wait at its current position.

**Type:** `float`

**Required:** Yes

### logistics_radius

Can't be negative.

**Type:** `float`

**Required:** Yes

### construction_radius

Can't be negative.

**Type:** `float`

**Required:** Yes

### charging_energy

The maximum power provided to each charging station.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
charging_energy = "1000kW"
```

### open_door_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### close_door_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### default_available_logistic_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_total_logistic_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_available_construction_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_total_construction_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_roboport_count_output_signal

**Type:** `SignalIDConnector`

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

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

### max_logistic_slots

**Type:** `LogisticFilterIndex`

**Optional:** Yes

### spawn_and_station_shadow_height_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0

### stationing_render_layer_swap_height

When robot ascends or descends to this roboport, at which height is should switch between `"air-object"` and `"object"` [render layer](prototype:RenderLayer).

**Type:** `float`

**Optional:** Yes

**Default:** 0.87

### draw_logistic_radius_visualization

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_construction_radius_visualization

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### recharging_light

The light emitted when charging a robot.

**Type:** `LightDefinition`

**Optional:** Yes

### charging_station_count

How many charging points this roboport has. If this is 0, the length of the charging_offsets table is used to calculate the charging station count.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### charging_station_count_affected_by_quality

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### charging_distance

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### charging_station_shift

**Type:** `Vector`

**Optional:** Yes

### charging_threshold_distance

Unused.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### robot_vertical_acceleration

**Type:** `float`

**Optional:** Yes

**Default:** 0.01

### stationing_offset

The offset from the center of the roboport at which robots will enter and exit.

**Type:** `Vector`

**Optional:** Yes

### robot_limit

Unused.

**Type:** `ItemCountType`

**Optional:** Yes

**Default:** "max uint"

### robots_shrink_when_entering_and_exiting

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### charging_offsets

The offsets from the center of the roboport at which robots will charge. Only used if `charging_station_count` is equal to 0.

**Type:** Array[`Vector`]

**Optional:** Yes

### logistics_connection_distance

Must be >= `logistics_radius`.

**Type:** `float`

**Optional:** Yes

**Default:** "value of `logistics_radius`"

