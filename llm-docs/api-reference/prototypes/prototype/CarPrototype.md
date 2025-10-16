# CarPrototype

Entity with specialized properties for acceleration, braking, and turning.

**Parent:** [VehiclePrototype](VehiclePrototype.md)
**Type name:** `car`

## Properties

### animation

Animation speed 1 means 1 frame per tile.

**Type:** `RotatedAnimation`

**Optional:** Yes

### effectivity

Modifies the efficiency of energy transfer from burner output to wheels.

**Type:** `double`

**Required:** Yes

### consumption

**Type:** `Energy`

**Required:** Yes

### rotation_speed

**Type:** `double`

**Required:** Yes

### rotation_snap_angle

Vehicle will snap the vertical, horizontal or diagonal axis if it's within this angle

**Type:** `double`

**Required:** Yes

### energy_source

**Type:** `BurnerEnergySource` | `VoidEnergySource`

**Required:** Yes

### turret_animation

Animation speed 1 means 1 frame per tile.

**Type:** `RotatedAnimation`

**Optional:** Yes

### light_animation

Must have the same frame count as `animation`.

**Type:** `RotatedAnimation`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### tank_driving

If this car prototype uses tank controls to drive.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### auto_sort_inventory

If this car prototype keeps the trunk inventory sorted.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### has_belt_immunity

If this car is immune to movement by belts.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### immune_to_tree_impacts

If this car gets damaged by driving over/against [trees](prototype:TreePrototype).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### immune_to_rock_impacts

If this car gets damaged by driving over/against [rocks](prototype:SimpleEntityPrototype::count_as_rock_for_filtered_deconstruction).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### immune_to_cliff_impacts

If this car gets damaged by driving against [cliffs](prototype:CliffPrototype).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### turret_rotation_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0.01

### turret_return_timeout

Timeout in ticks specifying how long the turret must be inactive to return to the default position.

**Type:** `uint32`

**Optional:** Yes

**Default:** 60

### inventory_size

Size of the car inventory.

**Type:** `ItemStackIndex`

**Required:** Yes

### trash_inventory_size

If set to 0 then the car will not have a Logistics tab.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### light

**Type:** `LightDefinition`

**Optional:** Yes

### sound_no_fuel

**Type:** `Sound`

**Optional:** Yes

### darkness_to_render_light_animation

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### track_particle_triggers

**Type:** `FootstepTriggerEffectList`

**Optional:** Yes

### guns

The names of the  [GunPrototype](prototype:GunPrototype)s this car prototype uses.

**Type:** Array[`ItemID`]

**Optional:** Yes

