# GroupAttackAchievementPrototype

This prototype is used for receiving an achievement when the player gets attacked due to pollution.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `group-attack-achievement`

## Properties

### amount

This will trigger the achievement, if the player receives this amount of attacks. **Note**: The default achievement "it stinks and they don't like it" uses the amount of 1. (As in getting attacked once.)

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

**Examples:**

```
amount = 10
```

### entities

The achievement is only triggered if the attacking group of enemies contains at least one of the entities listed here.

**Type:** Array[`EntityID`]

**Optional:** Yes

### attack_type

The type of attack that triggers this achievement. "autonomous" attacks are triggered in response to pollution or a territory disturbance. "distraction" attacks are in response to taking damage or seeing a nearby enemy. "scripted" attacks are triggered from mods.

**Type:** `"autonomous"` | `"distraction"` | `"scripted"`

**Optional:** Yes

