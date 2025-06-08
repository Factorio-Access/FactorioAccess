# UseEntityInEnergyProductionAchievementPrototype

This prototype is used for receiving an achievement when the player produces energy by entity.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### entity

**Type:** `EntityID`

This entity is needed to produce energy, for the player to complete the achievement.

### Optional Properties

#### consumed_condition

**Type:** `ItemIDFilter`

This item need to be consumed before gaining the achievement.

#### produced_condition

**Type:** `ItemIDFilter`

This item needs to be produced before gaining the achievement.

#### required_to_build

**Type:** `EntityID`

This item need to be built before gaining the achievement.

