# ResearchAchievementPrototype

This prototype is used for receiving an achievement when the player completes a specific research.

**Parent:** `AchievementPrototype`

## Properties

### Optional Properties

#### research_all

**Type:** `boolean`

Mandatory if `technology` is not defined.

This will only trigger if the player has learned every research in the game.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### technology

**Type:** `TechnologyID`

Mandatory if `research_all` is not defined.

Researching this technology will trigger the achievement.

