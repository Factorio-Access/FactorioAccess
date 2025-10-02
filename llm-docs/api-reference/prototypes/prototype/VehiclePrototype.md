# VehiclePrototype

Abstract base of all vehicles.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### weight

Must be positive. Weight of the entity used for physics calculation when car hits something.

**Type:** `double`

**Required:** Yes

### braking_power

Must be positive. There is no functional difference between the two ways to set braking power/force.

**Type:** `Energy` | `double`

**Required:** Yes

### friction

Must be positive. There is no functional difference between the two ways to set friction force.

**Type:** `double`

**Required:** Yes

### energy_per_hit_point

The (movement) energy used per hit point (1 hit point = 1 health damage) taken and dealt for this vehicle during collisions. The smaller the number, the more damage this vehicle and the rammed entity take during collisions: `damage = energy / energy_per_hit_point`.

**Type:** `double`

**Required:** Yes

### terrain_friction_modifier

Must be in the [0, 1] interval.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### impact_speed_to_volume_ratio

**Type:** `double`

**Optional:** Yes

**Default:** 5.0

### stop_trigger_speed

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### crash_trigger

**Type:** `TriggerEffect`

**Optional:** Yes

### stop_trigger

**Type:** `TriggerEffect`

**Optional:** Yes

### equipment_grid

The name of the [EquipmentGridPrototype](prototype:EquipmentGridPrototype) this vehicle has.

**Type:** `EquipmentGridID`

**Optional:** Yes

### minimap_representation

The sprite that represents this vehicle on the map/minimap.

**Type:** `Sprite`

**Optional:** Yes

### selected_minimap_representation

The sprite that represents this vehicle on the map/minimap when it is selected.

**Type:** `Sprite`

**Optional:** Yes

### allow_passengers

Determines whether this vehicle accepts passengers. This includes both drivers and gunners, if applicable.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### deliver_category

Name of a [DeliverCategory](prototype:DeliverCategory).

**Type:** `string`

**Optional:** Yes

**Default:** ""

### chunk_exploration_radius

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### allow_remote_driving

**Type:** `boolean`

**Optional:** Yes

**Default:** False

