# ArtilleryWagonPrototype

An [artillery wagon](https://wiki.factorio.com/Artillery_wagon).

**Parent:** `RollingStockPrototype`

## Properties

### Mandatory Properties

#### ammo_stack_limit

**Type:** `ItemCountType`

Must be > 0.

#### gun

**Type:** `ItemID`

Name of a [GunPrototype](prototype:GunPrototype).

#### inventory_size

**Type:** `ItemStackIndex`

Must be > 0.

#### manual_range_modifier

**Type:** `double`

Must be > 0.

#### turret_rotation_speed

**Type:** `double`



### Optional Properties

#### automated_ammo_count

**Type:** `ItemCountType`

Must be > 0.

#### cannon_barrel_light_direction

**Type:** `Vector3D`

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

#### cannon_barrel_pictures

**Type:** `RollingStockRotatedSlopedGraphics`



#### cannon_barrel_recoil_shiftings

**Type:** ``Vector3D`[]`



#### cannon_barrel_recoil_shiftings_load_correction_matrix

**Type:** ``Vector3D`[]`

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

#### cannon_base_height

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### cannon_base_pictures

**Type:** `RollingStockRotatedSlopedGraphics`



#### cannon_base_shift_when_horizontal

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### cannon_base_shift_when_vertical

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### cannon_parking_frame_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### cannon_parking_speed

**Type:** `float`

Must be positive.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### disable_automatic_firing

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### rotating_sound

**Type:** `InterruptibleSound`



#### turn_after_shooting_cooldown

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

