# EntityWithHealthPrototype

Abstract base of all entities with health in the game.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Abstract:** Yes

## Examples

```
{
  type = "container",
  name = "wooden-chest",
  icon = "__base__/graphics/icons/wooden-chest.png",
  flags = { "placeable-neutral", "player-creation" },
  minable = { mining_time = 1, result = "wooden-chest" },
  max_health = 100,
  corpse = "small-remnants",
  collision_box = { {-0.35, -0.35}, {0.35, 0.35} },
  fast_replaceable_group = "container",
  selection_box = { {-0.5, -0.5}, {0.5, 0.5} },
  inventory_size = 16,
  open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
  close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
  picture =
  {
    filename = "__base__/graphics/entity/wooden-chest/wooden-chest.png",
    priority = "extra-high",
    width = 46,
    height = 33,
    shift = {0.25, 0.015625}
  }
}
```

## Properties

### max_health

The unit health can never go over the maximum. Default health of units on creation is set to max. Must be greater than 0.

**Type:** `float`

**Optional:** Yes

**Default:** 10

**Examples:**

```
max_health = 50
```

### healing_per_tick

The amount of health automatically regenerated per tick. The entity must be active for this to work.

**Type:** `float`

**Optional:** Yes

**Default:** 0

**Examples:**

```
healing_per_tick = 0.01
```

### repair_speed_modifier

Multiplier of [RepairToolPrototype::speed](prototype:RepairToolPrototype::speed) for this entity prototype.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### dying_explosion

The entities that are spawned in place of this one when it dies.

**Type:** `ExplosionDefinition` | Array[`ExplosionDefinition`]

**Optional:** Yes

### dying_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### damaged_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### loot

The loot is dropped on the ground when the entity is killed.

**Type:** Array[`LootItem`]

**Optional:** Yes

**Examples:**

```
loot =
{
  {
    count_max = 10,
    count_min = 2,
    item = "stone",
    probability = 1
  }
}
```

### resistances

See [damage](https://wiki.factorio.com/Damage).

**Type:** Array[`Resistance`]

**Optional:** Yes

**Examples:**

```
resistances =
{
  {
    type = "fire",
    percent = 80
  },
  {
    type = "explosion",
    percent = 30
  }
}
```

### attack_reaction

**Type:** `AttackReactionItem` | Array[`AttackReactionItem`]

**Optional:** Yes

**Default:** "Empty"

### repair_sound

Played when this entity is repaired with a [RepairToolPrototype](prototype:RepairToolPrototype).

**Type:** `Sound`

**Optional:** Yes

**Default:** "Utility sound defaultManualRepair"

### alert_when_damaged

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### hide_resistances

Whether the resistances of this entity should be hidden in the entity tooltip.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### create_ghost_on_death

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### random_corpse_variation

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### integration_patch_render_layer

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### corpse

Specifies the names of the [CorpsePrototype](prototype:CorpsePrototype) to be used when this entity dies.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

**Default:** "Empty"

### integration_patch

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

Sprite drawn on ground under the entity to make it feel more integrated into the ground.

**Type:** `Sprite4Way`

**Optional:** Yes

### overkill_fraction

Fraction of health by which predicted damage must be exceeded before entity is considered as "predicted to die" causing turrets (and others) to stop shooting more projectiles. If entity is healing it is better to keep larger margin to avoid cases where not enough projectiles goes towards a target and it heals causing it to survive all the incoming projectiles. If entity does not heal, margin may be reduced. Must be >= 0.

**Type:** `float`

**Optional:** Yes

**Default:** 0.05

