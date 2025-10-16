# UseEntityInEnergyProductionAchievementPrototype

This prototype is used for receiving an achievement when the player produces energy by entity.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `use-entity-in-energy-production-achievement`

## Properties

### entity

This entity is needed to produce energy, for the player to complete the achievement.

**Type:** `EntityID`

**Required:** Yes

**Examples:**

```
entity = "steam-engine"
```

### consumed_condition

This item need to be consumed before gaining the achievement.

**Type:** `ItemIDFilter`

**Optional:** Yes

**Examples:**

```
consumed_condition = "uranium-fuel-cell"
```

### produced_condition

This item needs to be produced before gaining the achievement.

**Type:** `ItemIDFilter`

**Optional:** Yes

### required_to_build

This item need to be built before gaining the achievement.

**Type:** `EntityID`

**Optional:** Yes

**Examples:**

```
required_to_build = "nuclear-reactor"
```

