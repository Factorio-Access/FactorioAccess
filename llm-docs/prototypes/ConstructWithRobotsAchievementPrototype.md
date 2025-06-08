# ConstructWithRobotsAchievementPrototype

This prototype is used for receiving an achievement when the player constructs enough entities with construction robots.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

### Optional Properties

#### amount

**Type:** `uint32`

This will trigger the achievement, if enough entities were placed using construction robots.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### more_than_manually

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

