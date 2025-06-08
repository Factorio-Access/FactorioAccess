# ProjectilePrototype

Entity with limited lifetime that can hit other entities and has triggers when this happens.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### acceleration

**Type:** `double`

Must be != 0 if `turning_speed_increases_exponentially_with_projectile_speed` is true.

### Optional Properties

#### action

**Type:** `Trigger`

Executed when the projectile hits something.

#### animation

**Type:** `RotatedAnimationVariations`



#### direction_only

**Type:** `boolean`

Setting this to true can be used to disable projectile homing behaviour.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### enable_drawing_with_mask

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### final_action

**Type:** `Trigger`

Executed when the projectile hits something, after `action` and only if the entity that was hit was destroyed. The projectile is destroyed right after the final_action.

#### force_condition

**Type:** `ForceCondition`



**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### height

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### hit_at_collision_position

**Type:** `boolean`

When true the entity is hit at the position on its collision box the projectile first collides with. When false the entity is hit at its own position.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### hit_collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"projectile/hit"`.

#### light

**Type:** `LightDefinition`



#### max_speed

**Type:** `double`

Must be greater than or equal to 0.

**Default:** `MAX_DOUBLE`

#### piercing_damage

**Type:** `float`

Whenever an entity is hit by the projectile, this number gets reduced by the health of the entity. If the number is then below 0, the `final_action` is applied and the projectile destroyed. Otherwise, the projectile simply continues to its destination.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### rotatable

**Type:** `boolean`

Whether the animation of the projectile is rotated to match the direction of travel.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### shadow

**Type:** `RotatedAnimationVariations`



#### smoke

**Type:** ``SmokeSource`[]`



#### speed_modifier

**Type:** `Vector`



**Default:** ``{1, 1}``

#### turn_speed

**Type:** `float`

Must be greater than or equal to 0.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### turning_speed_increases_exponentially_with_projectile_speed

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

