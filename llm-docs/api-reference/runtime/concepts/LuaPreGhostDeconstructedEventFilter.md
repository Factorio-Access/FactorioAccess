# LuaPreGhostDeconstructedEventFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"ghost"` | `"rail"` | `"rail-signal"` | `"rolling-stock"` | `"robot-with-logistics-interface"` | `"vehicle"` | `"turret"` | `"crafting-machine"` | `"wall-connectable"` | `"transport-belt-connectable"` | `"circuit-network-connectable"` | `"type"` | `"name"` | `"ghost_type"` | `"ghost_name"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

