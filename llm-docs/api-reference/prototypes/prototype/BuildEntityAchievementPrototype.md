# BuildEntityAchievementPrototype

This prototype is used for receiving an achievement when the player builds an entity.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `build-entity-achievement`

## Properties

### to_build

This will trigger the achievement, if this entity is placed.

**Type:** `EntityID`

**Required:** Yes

**Examples:**

```
to_build = "locomotive"
```

### amount

How many entities need to be built.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### limited_to_one_game

If this is false, the player carries over their statistics from this achievement through all their saves.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### within

The achievement must be completed within this time limit.

**Type:** `MapTick`

**Optional:** Yes

**Default:** "`math.huge`"

**Examples:**

```
within = 60 * 60 * 60 * 8 -- 8 hours
```

