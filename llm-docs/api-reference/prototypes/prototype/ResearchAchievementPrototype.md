# ResearchAchievementPrototype

This prototype is used for receiving an achievement when the player completes a specific research.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `research-achievement`

## Properties

### technology

Mandatory if `research_all` is not defined.

Researching this technology will trigger the achievement.

**Type:** `TechnologyID`

**Optional:** Yes

**Examples:**

```
technology = "oil-processing"
```

### research_all

Mandatory if `technology` is not defined.

This will only trigger if the player has learned every research in the game.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Examples:**

```
research_all = true
```

