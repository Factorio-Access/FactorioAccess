# CarPrototype

Entity with specialized properties for acceleration, braking, and turning.

**Parent:** `VehiclePrototype`

## Properties

### Mandatory Properties

#### consumption

**Type:** `Energy`



#### effectivity

**Type:** `double`

Modifies the efficiency of energy transfer from burner output to wheels.

#### energy_source

**Type:** 



#### inventory_size

**Type:** `ItemStackIndex`

Size of the car inventory.

#### rotation_snap_angle

**Type:** `double`

Vehicle will snap the vertical, horizontal or diagonal axis if it's within this angle

#### rotation_speed

**Type:** `double`



### Optional Properties

#### animation

**Type:** `RotatedAnimation`

Animation speed 1 means 1 frame per tile.

#### auto_sort_inventory

**Type:** `boolean`

If this car prototype keeps the trunk inventory sorted.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### darkness_to_render_light_animation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.3}`

#### guns

**Type:** ``ItemID`[]`

The names of the  [GunPrototype](prototype:GunPrototype)s this car prototype uses.

#### has_belt_immunity

**Type:** `boolean`

If this car is immune to movement by belts.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### immune_to_cliff_impacts

**Type:** `boolean`

If this car gets damaged by driving against [cliffs](prototype:CliffPrototype).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### immune_to_rock_impacts

**Type:** `boolean`

If this car gets damaged by driving over/against [rocks](prototype:SimpleEntityPrototype::count_as_rock_for_filtered_deconstruction).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### immune_to_tree_impacts

**Type:** `boolean`

If this car gets damaged by driving over/against [trees](prototype:TreePrototype).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### light

**Type:** `LightDefinition`



#### light_animation

**Type:** `RotatedAnimation`

Must have the same frame count as `animation`.

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### sound_no_fuel

**Type:** `Sound`



#### tank_driving

**Type:** `boolean`

If this car prototype uses tank controls to drive.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### track_particle_triggers

**Type:** `FootstepTriggerEffectList`



#### trash_inventory_size

**Type:** `ItemStackIndex`

If set to 0 then the car will not have a Logistics tab.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### turret_animation

**Type:** `RotatedAnimation`

Animation speed 1 means 1 frame per tile.

#### turret_return_timeout

**Type:** `uint32`

Timeout in ticks specifying how long the turret must be inactive to return to the default position.

**Default:** `{'complex_type': 'literal', 'value': 60}`

#### turret_rotation_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.01}`

