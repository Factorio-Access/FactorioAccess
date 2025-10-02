# UseItemAchievementPrototype

This prototype is used for receiving an achievement when the player uses a capsule.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `use-item-achievement`

## Properties

### to_use

This will trigger the achievement, if this capsule is used.

**Type:** `ItemID`

**Required:** Yes

**Examples:**

```
to_use = "raw-fish"
```

### limit_quality

**Type:** `QualityID`

**Required:** Yes

### amount

How many capsules need to be used.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### limited_to_one_game

If this is false, the player carries over their statistics from this achievement through all their saves.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

