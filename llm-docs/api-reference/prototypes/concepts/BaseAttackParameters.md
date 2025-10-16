# BaseAttackParameters

The abstract base of all [AttackParameters](prototype:AttackParameters).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### range

Before an entity can attack, the distance (in tiles) between the entity and target must be less than or equal to this.

**Type:** `float`

**Required:** Yes

### cooldown

Number of ticks in which it will be possible to shoot again. If < 1, multiple shots can be performed in one tick.

**Type:** `float`

**Required:** Yes

### min_range

The minimum distance (in tiles) between an entity and target. If a unit's target is less than this, the unit will attempt to move away before attacking. A [flamethrower turret](https://wiki.factorio.com/Flamethrower_turret) does not move, but has a minimum range. Less than this, it is unable to target an enemy.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### turn_range

If this is <= 0, it is set to 1. Arc from 0 to 1, so for example 0.25 is 90°. Used by the [flamethrower turret](https://wiki.factorio.com/Flamethrower_turret) in the base game. Arcs greater than 0.5 but less than 1 will be clamped to 0.5 as targeting in arcs larger than half circle is [not implemented](https://forums.factorio.com/94654).

**Type:** `float`

**Optional:** Yes

**Default:** 1

### fire_penalty

Used when searching for the nearest enemy, when this is > 0, enemies that aren't burning are preferred over burning enemies. Definition of "burning" for this: Entity has sticker attached to it, and the sticker has a [spread_fire_entity](prototype:StickerPrototype::spread_fire_entity) set.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### rotate_penalty

A higher penalty will discourage turrets from targeting units that would take longer to turn to face.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### health_penalty

A higher penalty will discourage turrets from targeting units with higher health. A negative penalty will encourage turrets to target units with higher health.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### range_mode

**Type:** `RangeMode`

**Optional:** Yes

**Default:** "center-to-center"

### min_attack_distance

If less than `range`, the entity will choose a random distance between `range` and `min_attack_distance` and attack from that distance.

**Type:** `float`

**Optional:** Yes

**Default:** "equal to `range` property"

### damage_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

### ammo_consumption_modifier

Must be greater than or equal to `0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### cooldown_deviation

Must be between `0` and `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### warmup

Number of ticks it takes for the weapon to actually shoot after the order for shooting has been made. This also allows to "adjust" the shooting animation to the effect of shooting.

[CapsuleActions](prototype:CapsuleAction) cannot have attack parameters with non-zero warmup.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### lead_target_for_projectile_speed

Setting this to anything but zero causes homing projectiles to aim for the predicted location based on enemy movement instead of the current enemy location. If set, this property specifies the distance travelled per tick of the fired projectile.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### lead_target_for_projectile_delay

Setting this to anything but zero causes projectiles to aim for the predicted location based on enemy movement instead of the current enemy location. If set, this property adds a flat number of ticks atop `lead_target_for_projectile_speed` that the shooter must lead.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### movement_slow_down_cooldown

**Type:** `float`

**Optional:** Yes

**Default:** "equal to `cooldown` property"

### movement_slow_down_factor

**Type:** `double`

**Optional:** Yes

**Default:** 1

### ammo_type

Can be mandatory.

**Type:** `AmmoType`

**Optional:** Yes

### activation_type

Used in tooltips to set the tooltip category. It is also used to get the locale keys for activation instructions and speed of the action for the tooltip.

For example, an activation_type of "throw" will result in the tooltip category "thrown" and the tooltip locale keys "gui.instruction-to-throw" and "description.throwing-speed".

**Type:** `"shoot"` | `"throw"` | `"consume"` | `"activate"`

**Optional:** Yes

**Default:** "shoot"

### sound

Played once at the start of the attack if these are [ProjectileAttackParameters](prototype:ProjectileAttackParameters).

**Type:** `LayeredSound`

**Optional:** Yes

### animation

**Type:** `RotatedAnimation`

**Optional:** Yes

### cyclic_sound

Played during the attack.

**Type:** `CyclicSound`

**Optional:** Yes

### use_shooter_direction

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### ammo_categories

Mandatory if `ammo_category` is not defined.

**Type:** Array[`AmmoCategoryID`]

**Optional:** Yes

### ammo_category

Mandatory if `ammo_categories` is not defined.

**Type:** `AmmoCategoryID`

**Optional:** Yes

### true_collinear_ejection

Projectile will be creation position and orientation will be collinear with shooter and target (unless offset projectile center is specified). Used for railgun turrets to avoid unexpected friendly fire incidents.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

