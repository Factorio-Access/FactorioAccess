# DontUseEntityInEnergyProductionAchievementPrototype

This prototype is used for receiving an achievement when the player finishes the game without receiving energy from a specific energy source.

**Parent:** [AchievementPrototypeWithCondition](AchievementPrototypeWithCondition.md)
**Type name:** `dont-use-entity-in-energy-production-achievement`

## Properties

### excluded

This will **not** disable the achievement, if this entity is placed, and you have received any amount of power from it.

**Type:** `EntityID` | Array[`EntityID`]

**Required:** Yes

**Examples:**

```
excluded = {"steam-engine", "steam-turbine"}
```

### included

This will disable the achievement, if this entity is placed, and you have received any amount of power from it. If you finish the game without receiving power from this entity, you receive the achievement.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

**Examples:**

```
included = "solar-panel"
```

### last_hour_only

If `true`, the achievements will only be checked for the last hour of the game, independently of finishing the game.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### minimum_energy_produced

The minimum amount of energy that needs to be produced by the allowed entities to trigger the achievement.

**Type:** `Energy`

**Optional:** Yes

**Default:** "0J"

