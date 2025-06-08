# RoboportPrototype

A [roboport](https://wiki.factorio.com/Roboport).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### charge_approach_distance

**Type:** `float`

The distance (in tiles) from the roboport at which robots will wait to charge. Notably, if the robot is already in range, then it will simply wait at its current position.

#### charging_energy

**Type:** `Energy`

The maximum power provided to each charging station.

#### construction_radius

**Type:** `float`

Can't be negative.

#### energy_source

**Type:** 

The roboport's energy source.

#### energy_usage

**Type:** `Energy`

The amount of energy the roboport uses when idle.

#### logistics_radius

**Type:** `float`

Can't be negative.

#### material_slots_count

**Type:** `ItemStackIndex`

The number of repair pack slots in the roboport.

#### recharge_minimum

**Type:** `Energy`

Minimum charge that the roboport has to have after a blackout (0 charge/buffered energy) to begin working again. Additionally, freshly placed roboports will have their energy buffer filled with `0.25 × recharge_minimum` energy.

Must be larger than or equal to `energy_usage` otherwise during low power the roboport will toggle on and off every tick.

#### request_to_open_door_timeout

**Type:** `uint32`



#### robot_slots_count

**Type:** `ItemStackIndex`

The number of robot slots in the roboport.

#### spawn_and_station_height

**Type:** `float`

Presumably states the height of the charging stations and thus an additive offset for the charging_offsets.

### Optional Properties

#### base

**Type:** `Sprite`



#### base_animation

**Type:** `Animation`

The animation played when the roboport is idle.

#### base_patch

**Type:** `Sprite`



#### charging_distance

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### charging_offsets

**Type:** ``Vector`[]`

The offsets from the center of the roboport at which robots will charge. Only used if `charging_station_count` is equal to 0.

#### charging_station_count

**Type:** `uint32`

How many charging points this roboport has. If this is 0, the length of the charging_offsets table is used to calculate the charging station count.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### charging_station_count_affected_by_quality

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### charging_station_shift

**Type:** `Vector`



#### charging_threshold_distance

**Type:** `float`

Unused.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### close_door_trigger_effect

**Type:** `TriggerEffect`



#### default_available_construction_output_signal

**Type:** `SignalIDConnector`



#### default_available_logistic_output_signal

**Type:** `SignalIDConnector`



#### default_roboport_count_output_signal

**Type:** `SignalIDConnector`



#### default_total_construction_output_signal

**Type:** `SignalIDConnector`



#### default_total_logistic_output_signal

**Type:** `SignalIDConnector`



#### door_animation_down

**Type:** `Animation`



#### door_animation_up

**Type:** `Animation`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_construction_radius_visualization

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_logistic_radius_visualization

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### frozen_patch

**Type:** `Sprite`



#### logistics_connection_distance

**Type:** `float`

Must be >= `logistics_radius`.

**Default:** `value of `logistics_radius``

#### max_logistic_slots

**Type:** `LogisticFilterIndex`



#### open_door_trigger_effect

**Type:** `TriggerEffect`



#### radar_range

**Type:** `uint32`

Defaults to the max of logistic range or construction range rounded up to chunks.

#### radar_visualisation_color

**Type:** `Color`



#### recharging_animation

**Type:** `Animation`

The animation played at each charging point when a robot is charging there.

#### recharging_light

**Type:** `LightDefinition`

The light emitted when charging a robot.

#### robot_limit

**Type:** `ItemCountType`

Unused.

**Default:** `max uint`

#### robot_vertical_acceleration

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.01}`

#### robots_shrink_when_entering_and_exiting

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### spawn_and_station_shadow_height_offset

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### stationing_offset

**Type:** `Vector`

The offset from the center of the roboport at which robots will enter and exit.

#### stationing_render_layer_swap_height

**Type:** `float`

When robot ascends or descends to this roboport, at which height is should switch between `"air-object"` and `"object"` [render layer](prototype:RenderLayer).

**Default:** `{'complex_type': 'literal', 'value': 0.87}`

