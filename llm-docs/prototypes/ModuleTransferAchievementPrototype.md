# ModuleTransferAchievementPrototype

This prototype is used for receiving an achievement when the player moves a module with the cursor.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### module

**Type:** 

This will trigger the achievement, if this module is transferred.

### Optional Properties

#### amount

**Type:** `uint32`

How many modules need to be transferred.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

**Default:** `{'complex_type': 'literal', 'value': False}`

