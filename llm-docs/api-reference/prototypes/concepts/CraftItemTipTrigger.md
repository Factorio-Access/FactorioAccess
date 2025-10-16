# CraftItemTipTrigger

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"craft-item"`

**Required:** Yes

### item

**Type:** `ItemID`

**Optional:** Yes

### event_type

**Type:** `"crafting-of-single-item-ordered"` | `"crafting-of-multiple-items-ordered"` | `"crafting-finished"`

**Required:** Yes

### consecutive

Can only be used when `event_type` is `"crafting-finished"`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

