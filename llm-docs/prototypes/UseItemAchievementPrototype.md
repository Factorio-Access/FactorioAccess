# UseItemAchievementPrototype

This prototype is used for receiving an achievement when the player uses a capsule.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### limit_quality

**Type:** `QualityID`



#### to_use

**Type:** `ItemID`

This will trigger the achievement, if this capsule is used.

### Optional Properties

#### amount

**Type:** `uint32`

How many capsules need to be used.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

**Default:** `{'complex_type': 'literal', 'value': False}`

