# VehiclePrototype

Abstract base of all vehicles.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### braking_power

**Type:** 

Must be positive. There is no functional difference between the two ways to set braking power/force.

#### energy_per_hit_point

**Type:** `double`

The (movement) energy used per hit point (1 hit point = 1 health damage) taken and dealt for this vehicle during collisions. The smaller the number, the more damage this vehicle and the rammed entity take during collisions: `damage = energy / energy_per_hit_point`.

#### friction

**Type:** `double`

Must be positive. There is no functional difference between the two ways to set friction force.

#### weight

**Type:** `double`

Must be positive. Weight of the entity used for physics calculation when car hits something.

### Optional Properties

#### allow_passengers

**Type:** `boolean`

Determines whether this vehicle accepts passengers. This includes both drivers and gunners, if applicable.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### allow_remote_driving

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### chunk_exploration_radius

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### crash_trigger

**Type:** `TriggerEffect`



#### deliver_category

**Type:** `string`

Name of a [DeliverCategory](prototype:DeliverCategory).

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### equipment_grid

**Type:** `EquipmentGridID`

The name of the [EquipmentGridPrototype](prototype:EquipmentGridPrototype) this vehicle has.

#### impact_speed_to_volume_ratio

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 5.0}`

#### minimap_representation

**Type:** `Sprite`

The sprite that represents this vehicle on the map/minimap.

#### selected_minimap_representation

**Type:** `Sprite`

The sprite that represents this vehicle on the map/minimap when it is selected.

#### stop_trigger

**Type:** `TriggerEffect`



#### stop_trigger_speed

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### terrain_friction_modifier

**Type:** `float`

Must be in the [0, 1] interval.

**Default:** `{'complex_type': 'literal', 'value': 1}`

