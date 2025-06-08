# EquipArmorAchievementPrototype

This prototype is used for receiving an achievement when the player equips armor.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### alternative_armor

**Type:** `ItemID`

The achievement will trigger if this armor or the other armor is equipped.

#### armor

**Type:** `ItemID`

The achievement will trigger if this armor or the alternative armor is equipped.

#### limit_quality

**Type:** `QualityID`



### Optional Properties

#### amount

**Type:** `uint32`

How many armors need to be equipped.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

**Default:** `{'complex_type': 'literal', 'value': False}`

