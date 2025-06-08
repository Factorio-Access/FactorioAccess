# LandMinePrototype

A [land mine](https://wiki.factorio.com/Land_mine).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### trigger_radius

**Type:** `double`



### Optional Properties

#### action

**Type:** `Trigger`



#### ammo_category

**Type:** `AmmoCategoryID`



#### force_die_on_attack

**Type:** `boolean`

Force the landmine to kill itself when exploding.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### picture_safe

**Type:** `Sprite`

The sprite of the landmine before it is armed (just after placing).

#### picture_set

**Type:** `Sprite`

The sprite of the landmine of a friendly force when it is armed.

#### picture_set_enemy

**Type:** `Sprite`

The sprite of the landmine of an enemy force when it is armed.

#### timeout

**Type:** `uint32`

Time between placing and the landmine being armed, in ticks.

**Default:** `{'complex_type': 'literal', 'value': 120}`

#### trigger_collision_mask

**Type:** `CollisionMaskConnector`

Collision mask that another entity must collide with to make this landmine blow up.

**Default:** `Value of UtilityConstants::building_collision_mask`

#### trigger_force

**Type:** `ForceCondition`



**Default:** `{'complex_type': 'literal', 'value': 'enemy'}`

#### trigger_interval

**Type:** `uint32`

Time between checks to detonate due to nearby enemies, in ticks. A larger time will be more performant.

**Default:** `{'complex_type': 'literal', 'value': 10}`

