# DontResearchBeforeResearchingAchievementPrototype

This prototype is used for receiving an achievement when the player researches with a specific science pack before unlocking another.

**Parent:** [AchievementPrototypeWithCondition](AchievementPrototypeWithCondition.md)
**Type name:** `dont-research-before-researching-achievement`

## Properties

### dont_research

This will disable the achievement, if technology unlocking this item is researched before meeting requirements.

**Type:** `ItemID` | Array[`ItemID`]

**Required:** Yes

**Examples:**

```
dont_research = {"production-science-pack", "utility-science-pack"}
```

### research_with

If you research technology using one of specified items, you receive the achievement.

**Type:** `ItemID` | Array[`ItemID`]

**Required:** Yes

**Examples:**

```
research_with = {"metallurgic-science-pack", "electromagnetic-science-pack", "agricultural-science-pack"}
```

