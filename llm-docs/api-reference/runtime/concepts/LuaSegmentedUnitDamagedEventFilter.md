# LuaSegmentedUnitDamagedEventFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"name"` | `"original-damage-amount"` | `"final-damage-amount"` | `"damage-type"` | `"final-health"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

