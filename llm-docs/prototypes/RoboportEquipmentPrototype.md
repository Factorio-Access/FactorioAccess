# RoboportEquipmentPrototype

Used by [personal roboport](https://wiki.factorio.com/Personal_roboport).

**Parent:** `EquipmentPrototype`

## Properties

### Mandatory Properties

#### charge_approach_distance

**Type:** `float`

Presumably, the distance from the roboport at which robots will wait to charge.

#### charging_energy

**Type:** `Energy`



#### construction_radius

**Type:** `float`

Can't be negative.

#### spawn_and_station_height

**Type:** `float`

Presumably states the height of the charging stations and thus an additive offset for the charging_offsets.

### Optional Properties

#### burner

**Type:** `BurnerEnergySource`

Add this is if the roboport should be fueled directly instead of using power from the equipment grid.

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

Distance in tiles. This defines how far away a robot can be from the charging spot and still be charged, however the bot is still required to reach a charging spot in the first place.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### draw_construction_radius_visualization

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_logistic_radius_visualization

**Type:** `boolean`

Unused, as roboport equipment does not have a logistic radius that could be drawn.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### power

**Type:** `Energy`

Mandatory if `burner` is defined.

The size of the buffer of the burner energy source, so effectively the amount of power that the energy source can produce per tick.

#### recharging_animation

**Type:** `Animation`

The animation played at each charging point when a robot is charging there.

#### recharging_light

**Type:** `LightDefinition`

The light emitted when charging a robot.

#### robot_limit

**Type:** `ItemCountType`

How many robots can exist in the network (cumulative).

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

#### spawn_minimum

**Type:** `Energy`

Minimum amount of energy that needs to available inside the roboport's buffer so that robots can be spawned.

**Default:** `0.2 * energy_source.buffer_capacity`

#### stationing_offset

**Type:** `Vector`

The offset from the center of the roboport at which robots will enter and exit.

#### stationing_render_layer_swap_height

**Type:** `float`

When robot ascends or descends to this roboport, at which height is should switch between `"air-object"` and `"object"` [render layer](prototype:RenderLayer).

**Default:** `{'complex_type': 'literal', 'value': 0.87}`

