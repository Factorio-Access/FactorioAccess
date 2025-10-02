# RoboportEquipmentPrototype

Used by [personal roboport](https://wiki.factorio.com/Personal_roboport).

**Parent:** [EquipmentPrototype](EquipmentPrototype.md)
**Type name:** `roboport-equipment`

## Properties

### recharging_animation

The animation played at each charging point when a robot is charging there.

**Type:** `Animation`

**Optional:** Yes

### spawn_and_station_height

Presumably states the height of the charging stations and thus an additive offset for the charging_offsets.

**Type:** `float`

**Required:** Yes

### charge_approach_distance

Presumably, the distance from the roboport at which robots will wait to charge.

**Type:** `float`

**Required:** Yes

### construction_radius

Can't be negative.

**Type:** `float`

**Required:** Yes

### charging_energy

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
charging_energy = "1000kW"
```

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

Unused, as roboport equipment does not have a logistic radius that could be drawn.

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

Distance in tiles. This defines how far away a robot can be from the charging spot and still be charged, however the bot is still required to reach a charging spot in the first place.

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

How many robots can exist in the network (cumulative).

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

### spawn_minimum

Minimum amount of energy that needs to available inside the roboport's buffer so that robots can be spawned.

**Type:** `Energy`

**Optional:** Yes

**Default:** "0.2 * energy_source.buffer_capacity"

### burner

Add this is if the roboport should be fueled directly instead of using power from the equipment grid.

**Type:** `BurnerEnergySource`

**Optional:** Yes

### power

Mandatory if `burner` is defined.

The size of the buffer of the burner energy source, so effectively the amount of power that the energy source can produce per tick.

**Type:** `Energy`

**Optional:** Yes

