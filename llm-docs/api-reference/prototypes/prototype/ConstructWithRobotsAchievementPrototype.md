# ConstructWithRobotsAchievementPrototype

This prototype is used for receiving an achievement when the player constructs enough entities with construction robots.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `construct-with-robots-achievement`

## Properties

### limited_to_one_game

If this is false, the player carries over their statistics from this achievement through all their saves.

**Type:** `boolean`

**Required:** Yes

### amount

This will trigger the achievement, if enough entities were placed using construction robots.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

**Examples:**

```
amount = 100
```

### more_than_manually

**Type:** `boolean`

**Optional:** Yes

**Default:** False

