# TilePrototypeFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"minable"` | `"autoplace"` | `"blueprintable"` | `"item-to-place"` | `"collision-mask"` | `"walking-speed-modifier"` | `"vehicle-friction-modifier"` | `"decorative-removal-probability"` | `"absorptions-per-second"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

