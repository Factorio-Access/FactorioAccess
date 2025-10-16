# GiveItemModifier

Note that when any technology prototype changes (regardless of which mod it belongs to), the game re-applies all researched technology effects, including `"give-item"` modifiers. This means that players will receive the item again, even if they already received it previously. This can be undesirable.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"give-item"`

**Required:** Yes

### use_icon_overlay_constant

If `false`, do not draw the small "constant" icon over the technology effect icon.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### item

**Type:** `ItemID`

**Required:** Yes

### quality

**Type:** `QualityID`

**Optional:** Yes

**Default:** "normal"

### count

**Type:** `ItemCountType`

**Optional:** Yes

**Default:** 1

