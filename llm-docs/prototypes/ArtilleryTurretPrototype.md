# ArtilleryTurretPrototype

An [artillery turret](https://wiki.factorio.com/Artillery_turret).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### ammo_stack_limit

**Type:** `ItemCountType`

Must be > 0.

#### cannon_base_shift

**Type:** `Vector3D`



#### gun

**Type:** `ItemID`

Name of a [GunPrototype](prototype:GunPrototype).

#### inventory_size

**Type:** `ItemStackIndex`

Must be > 0.

#### manual_range_modifier

**Type:** `double`

Must be positive.

#### turret_rotation_speed

**Type:** `double`



### Optional Properties

#### alert_when_attacking

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### automated_ammo_count

**Type:** `ItemCountType`

Must be > 0.

#### base_picture

**Type:** `Animation4Way`



#### base_picture_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### base_picture_secondary_draw_order

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### cannon_barrel_light_direction

**Type:** `Vector3D`

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

#### cannon_barrel_pictures

**Type:** `RotatedSprite`



#### cannon_barrel_recoil_shiftings

**Type:** ``Vector3D`[]`



#### cannon_barrel_recoil_shiftings_load_correction_matrix

**Type:** ``Vector3D`[]`

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

#### cannon_base_pictures

**Type:** `RotatedSprite`



#### cannon_parking_frame_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### cannon_parking_speed

**Type:** `float`

Must be positive.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### disable_automatic_firing

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### rotating_sound

**Type:** `InterruptibleSound`



#### turn_after_shooting_cooldown

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

