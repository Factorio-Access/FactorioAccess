# DontKillManuallyAchievementPrototype

This prototype is used for receiving an achievement when the player kill first entity using artillery.

**Parent:** [AchievementPrototypeWithCondition](AchievementPrototypeWithCondition.md)
**Type name:** `dont-kill-manually-achievement`

## Properties

### to_kill

This will disable the achievement, if this entity is killed manually. If you kill this entity with artillery first, you receive the achievement.

**Type:** `EntityID`

**Optional:** Yes

### type_not_to_kill

This will disable the achievement, if this entity type is killed manually. If you kill this entity type with artillery first, you receive the achievement.

**Type:** `string`

**Optional:** Yes

**Examples:**

```
type_not_to_kill = "unit-spawner"
```

