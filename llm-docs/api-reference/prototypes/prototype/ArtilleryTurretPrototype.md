# ArtilleryTurretPrototype

An [artillery turret](https://wiki.factorio.com/Artillery_turret).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `artillery-turret`

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

Must be positive.

**Type:** `double`

**Required:** Yes

### alert_when_attacking

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### disable_automatic_firing

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### base_picture_secondary_draw_order

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### base_picture_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### base_picture

**Type:** `Animation4Way`

**Optional:** Yes

### cannon_base_shift

**Type:** `Vector3D`

**Required:** Yes

### cannon_base_pictures

**Type:** `RotatedSprite`

**Optional:** Yes

### cannon_barrel_pictures

**Type:** `RotatedSprite`

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

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_connector

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

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

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

