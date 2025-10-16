# DontBuildEntityAchievementPrototype

This prototype is used for receiving an achievement when the player finishes the game without building a specific entity.

**Parent:** [AchievementPrototypeWithCondition](AchievementPrototypeWithCondition.md)
**Type name:** `dont-build-entity-achievement`

## Properties

### dont_build

This will disable the achievement, if this entity is placed. If you finish the game without building this entity, you receive the achievement.

**Type:** `EntityID` | Array[`EntityID`]

**Required:** Yes

**Examples:**

```
dont_build = {"bulk-inserter", "fluid-wagon"}
```

### amount

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### research_with

If you research technology using one of specified items before building entity, you receive the achievement.

**Type:** `ItemID` | Array[`ItemID`]

**Optional:** Yes

