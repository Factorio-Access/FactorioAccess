# ModuleTransferAchievementPrototype

This prototype is used for receiving an achievement when the player moves a module with the cursor.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `module-transfer-achievement`

## Properties

### module

This will trigger the achievement, if this module is transferred.

**Type:** `ItemID` | Array[`ItemID`]

**Required:** Yes

**Examples:**

```
module = "quality-module"
```

### amount

How many modules need to be transferred.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### limited_to_one_game

If this is false, the player carries over their statistics from this achievement through all their saves.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

