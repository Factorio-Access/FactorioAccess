# DontUseEntityInEnergyProductionAchievementPrototype

This prototype is used for receiving an achievement when the player finishes the game without receiving energy from a specific energy source.

**Parent:** `AchievementPrototypeWithCondition`

## Properties

### Mandatory Properties

#### excluded

**Type:** 

This will **not** disable the achievement, if this entity is placed, and you have received any amount of power from it.

### Optional Properties

#### included

**Type:** 

This will disable the achievement, if this entity is placed, and you have received any amount of power from it. If you finish the game without receiving power from this entity, you receive the achievement.

#### last_hour_only

**Type:** `boolean`

If `true`, the achievements will only be checked for the last hour of the game, independently of finishing the game.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### minimum_energy_produced

**Type:** `Energy`

The minimum amount of energy that needs to be produced by the allowed entities to trigger the achievement.

**Default:** `{'complex_type': 'literal', 'value': '0J'}`

