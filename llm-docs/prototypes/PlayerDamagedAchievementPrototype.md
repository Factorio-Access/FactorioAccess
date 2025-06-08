# PlayerDamagedAchievementPrototype

This prototype is used for receiving an achievement when the player receives damage.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### minimum_damage

**Type:** `float`

This will trigger the achievement, if the amount of damage taken by the dealer, is more than this.

#### should_survive

**Type:** `boolean`

This sets the achievement to only trigger, if you survive the minimum amount of damage. If you don't need to survive, false.

### Optional Properties

#### type_of_dealer

**Type:** `string`

This will trigger the achievement, if the player takes damage from this specific entity type.

**Default:** `{'complex_type': 'literal', 'value': ''}`

