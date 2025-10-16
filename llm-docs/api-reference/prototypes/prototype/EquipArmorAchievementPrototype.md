# EquipArmorAchievementPrototype

This prototype is used for receiving an achievement when the player equips armor.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `equip-armor-achievement`

## Properties

### armor

The achievement will trigger if this armor or the alternative armor is equipped.

**Type:** `ItemID`

**Required:** Yes

**Examples:**

```
armor = "power-armor-mk2"
```

### alternative_armor

The achievement will trigger if this armor or the other armor is equipped.

**Type:** `ItemID`

**Required:** Yes

**Examples:**

```
alternative_armor = "mech-armor"
```

### limit_quality

**Type:** `QualityID`

**Required:** Yes

### amount

How many armors need to be equipped.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### limited_to_one_game

If this is false, the player carries over their statistics from this achievement through all their saves.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

