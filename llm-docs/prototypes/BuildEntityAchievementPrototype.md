# BuildEntityAchievementPrototype

This prototype is used for receiving an achievement when the player builds an entity.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### to_build

**Type:** `EntityID`

This will trigger the achievement, if this entity is placed.

### Optional Properties

#### amount

**Type:** `uint32`

How many entities need to be built.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### within

**Type:** `MapTick`

The achievement must be completed within this time limit.

**Default:** ``math.huge``

