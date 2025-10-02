# ProjectileAttackParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"projectile"`

**Required:** Yes

### apply_projection_to_projectile_creation_position

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### projectile_center

When used with `projectile_creation_parameters`, this offsets what the turret's sprite looks at. Setting to `{0,1}` will cause the turret to aim one tile up from the target but the projectile will still aim for the entity. Can be used to give the illusion of height but can also confuse aim logic when set too high.

When used without `projectile_creation_parameters`, this sets the turret's rotation axis.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

### projectile_creation_distance

**Type:** `float`

**Optional:** Yes

**Default:** 0

### shell_particle

Used to show bullet shells/casings being ejected from the gun, see [artillery shell casings](https://factorio.com/blog/post/fff-345).

**Type:** `CircularParticleCreationSpecification`

**Optional:** Yes

### projectile_creation_parameters

Used to shoot projectiles from arbitrary points. Used by worms. If not set then the launch positions are calculated using `projectile_center` and `projectile_creation_distance`.

**Type:** `CircularProjectileCreationSpecification`

**Optional:** Yes

### projectile_orientation_offset

Used to shoot from different sides of the turret. Setting to `0.25` shoots from the right side, `0.5` shoots from the back, and `0.75` shoots from the left. The turret will look at the enemy as normal but the bullet will spawn from the offset position. Can be used to create right-handed weapons.

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** 0

### projectile_creation_offsets

Used to shoot from multiple points. The turret will look at the enemy as normal but the bullet will spawn from a random offset position. Can be used to create multi-barreled weapons.

**Type:** Array[`Vector`]

**Optional:** Yes

