# CreateEntityTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"create-entity"`

**Required:** Yes

### entity_name

The name of the entity that should be created.

**Type:** `EntityID`

**Required:** Yes

### offset_deviation

**Type:** `BoundingBox`

**Optional:** Yes

### trigger_created_entity

If `true`, the [on_trigger_created_entity](runtime:on_trigger_created_entity) event will be raised.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### check_buildability

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### show_in_tooltip

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### only_when_visible

Create the entity only when they are within a 200 tile range of any connected player.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tile_collision_mask

Entity creation will not occur if any tile matches the collision condition. Defaults to no collisions.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### offsets

If multiple offsets are specified, multiple entities are created. The projectile of the [Distractor capsule](https://wiki.factorio.com/Distractor_capsule) uses this property to spawn three Distractors.

**Type:** Array[`Vector`]

**Optional:** Yes

### as_enemy

If true, creates the entity as a member of the enemy force. If the surface.no_enemies_mode is true, the entity will not be created.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### ignore_no_enemies_mode

If true and `as_enemy` is true, allows the entity to be created even if the current surface.no_enemies_mode is true.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### find_non_colliding_position

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### abort_if_over_space

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### non_colliding_search_radius

**Type:** `double`

**Optional:** Yes

**Default:** 5

### non_colliding_search_precision

**Type:** `double`

**Optional:** Yes

**Default:** 0.2

### non_colliding_fail_result

Only loaded if `find_non_colliding_position` is defined.

**Type:** `Trigger`

**Optional:** Yes

### protected

The result entity will be protected from automated attacks of enemies.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

