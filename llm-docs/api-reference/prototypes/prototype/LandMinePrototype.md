# LandMinePrototype

A [land mine](https://wiki.factorio.com/Land_mine).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `land-mine`

## Properties

### picture_safe

The sprite of the landmine before it is armed (just after placing).

**Type:** `Sprite`

**Optional:** Yes

### picture_set

The sprite of the landmine of a friendly force when it is armed.

**Type:** `Sprite`

**Optional:** Yes

### trigger_radius

**Type:** `double`

**Required:** Yes

### picture_set_enemy

The sprite of the landmine of an enemy force when it is armed.

**Type:** `Sprite`

**Optional:** Yes

### timeout

Time between placing and the landmine being armed, in ticks.

**Type:** `uint32`

**Optional:** Yes

**Default:** 120

### trigger_interval

Time between checks to detonate due to nearby enemies, in ticks. A larger time will be more performant.

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### action

**Type:** `Trigger`

**Optional:** Yes

### ammo_category

**Type:** `AmmoCategoryID`

**Optional:** Yes

### force_die_on_attack

Force the landmine to kill itself when exploding.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### trigger_force

**Type:** `ForceCondition`

**Optional:** Yes

**Default:** "enemy"

### trigger_collision_mask

Collision mask that another entity must collide with to make this landmine blow up.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

**Default:** "Value of UtilityConstants::building_collision_mask"

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

