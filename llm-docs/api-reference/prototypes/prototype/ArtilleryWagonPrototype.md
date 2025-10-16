# ArtilleryWagonPrototype

An [artillery wagon](https://wiki.factorio.com/Artillery_wagon).

**Parent:** [RollingStockPrototype](RollingStockPrototype.md)
**Type name:** `artillery-wagon`

## Properties

### gun

Name of a [GunPrototype](prototype:GunPrototype).

**Type:** `ItemID`

**Required:** Yes

### inventory_size

Must be > 0.

**Type:** `ItemStackIndex`

**Required:** Yes

### ammo_stack_limit

Must be > 0.

**Type:** `ItemCountType`

**Required:** Yes

### automated_ammo_count

Must be > 0.

**Type:** `ItemCountType`

**Optional:** Yes

### turret_rotation_speed

**Type:** `double`

**Required:** Yes

### manual_range_modifier

Must be > 0.

**Type:** `double`

**Required:** Yes

### disable_automatic_firing

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### cannon_base_pictures

**Type:** `RollingStockRotatedSlopedGraphics`

**Optional:** Yes

### cannon_base_height

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### cannon_base_shift_when_vertical

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### cannon_base_shift_when_horizontal

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### cannon_barrel_pictures

**Type:** `RollingStockRotatedSlopedGraphics`

**Optional:** Yes

### rotating_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### turn_after_shooting_cooldown

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### cannon_parking_frame_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### cannon_parking_speed

Must be positive.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### cannon_barrel_recoil_shiftings

**Type:** Array[`Vector3D`]

**Optional:** Yes

### cannon_barrel_recoil_shiftings_load_correction_matrix

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

**Type:** Array[`Vector3D`]

**Optional:** Yes

### cannon_barrel_light_direction

Only loaded if `cannon_barrel_recoil_shiftings` is loaded.

**Type:** `Vector3D`

**Optional:** Yes

