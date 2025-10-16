# ProjectilePrototype

Entity with limited lifetime that can hit other entities and has triggers when this happens.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `projectile`

## Properties

### acceleration

Must be != 0 if `turning_speed_increases_exponentially_with_projectile_speed` is true.

**Type:** `double`

**Required:** Yes

### animation

**Type:** `RotatedAnimationVariations`

**Optional:** Yes

### rotatable

Whether the animation of the projectile is rotated to match the direction of travel.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### enable_drawing_with_mask

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### direction_only

Setting this to true can be used to disable projectile homing behaviour.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hit_at_collision_position

When true the entity is hit at the position on its collision box the projectile first collides with. When false the entity is hit at its own position.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### force_condition

**Type:** `ForceCondition`

**Optional:** Yes

**Default:** "all"

### piercing_damage

Whenever an entity is hit by the projectile, this number gets reduced by the health of the entity. If the number is then below 0, the `final_action` is applied and the projectile destroyed. Otherwise, the projectile simply continues to its destination.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_speed

Must be greater than or equal to 0.

**Type:** `double`

**Optional:** Yes

**Default:** "MAX_DOUBLE"

### turn_speed

Must be greater than or equal to 0.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### speed_modifier

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{1, 1}`"

### height

**Type:** `double`

**Optional:** Yes

**Default:** 1

### action

Executed when the projectile hits something.

**Type:** `Trigger`

**Optional:** Yes

### final_action

Executed when the projectile hits something, after `action` and only if the entity that was hit was destroyed. The projectile is destroyed right after the final_action.

**Type:** `Trigger`

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### smoke

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### hit_collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"projectile/hit"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### turning_speed_increases_exponentially_with_projectile_speed

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### shadow

**Type:** `RotatedAnimationVariations`

**Optional:** Yes

