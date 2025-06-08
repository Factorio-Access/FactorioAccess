# EntityWithHealthPrototype

Abstract base of all entities with health in the game.

**Parent:** `EntityPrototype`

## Properties

### Optional Properties

#### alert_when_damaged

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### attack_reaction

**Type:** 



**Default:** `Empty`

#### corpse

**Type:** 

Specifies the names of the [CorpsePrototype](prototype:CorpsePrototype) to be used when this entity dies.

**Default:** `Empty`

#### create_ghost_on_death

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### damaged_trigger_effect

**Type:** `TriggerEffect`



#### dying_explosion

**Type:** 

The entities that are spawned in place of this one when it dies.

#### dying_trigger_effect

**Type:** `TriggerEffect`



#### healing_per_tick

**Type:** `float`

The amount of health automatically regenerated per tick. The entity must be active for this to work.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### hide_resistances

**Type:** `boolean`

Whether the resistances of this entity should be hidden in the entity tooltip.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### integration_patch

**Type:** `Sprite4Way`

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

Sprite drawn on ground under the entity to make it feel more integrated into the ground.

#### integration_patch_render_layer

**Type:** `RenderLayer`

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### loot

**Type:** ``LootItem`[]`

The loot is dropped on the ground when the entity is killed.

#### max_health

**Type:** `float`

The unit health can never go over the maximum. Default health of units on creation is set to max. Must be greater than 0.

**Default:** `{'complex_type': 'literal', 'value': 10}`

#### overkill_fraction

**Type:** `float`

Fraction of health by which predicted damage must be exceeded before entity is considered as "predicted to die" causing turrets (and others) to stop shooting more projectiles. If entity is healing it is better to keep larger margin to avoid cases where not enough projectiles goes towards a target and it heals causing it to survive all the incoming projectiles. If entity does not heal, margin may be reduced. Must be >= 0.

**Default:** `{'complex_type': 'literal', 'value': 0.05}`

#### random_corpse_variation

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### repair_sound

**Type:** `Sound`

Played when this entity is repaired with a [RepairToolPrototype](prototype:RepairToolPrototype).

**Default:** `Utility sound defaultManualRepair`

#### repair_speed_modifier

**Type:** `float`

Multiplier of [RepairToolPrototype::speed](prototype:RepairToolPrototype::speed) for this entity prototype.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### resistances

**Type:** ``Resistance`[]`

See [damage](https://wiki.factorio.com/Damage).

