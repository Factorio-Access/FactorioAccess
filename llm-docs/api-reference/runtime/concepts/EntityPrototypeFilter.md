# EntityPrototypeFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"flying-robot"` | `"robot-with-logistics-interface"` | `"rail"` | `"ghost"` | `"explosion"` | `"vehicle"` | `"crafting-machine"` | `"rolling-stock"` | `"turret"` | `"transport-belt-connectable"` | `"wall-connectable"` | `"buildable"` | `"placable-in-editor"` | `"clonable"` | `"selectable"` | `"hidden"` | `"entity-with-health"` | `"building"` | `"fast-replaceable"` | `"uses-direction"` | `"minable"` | `"circuit-connectable"` | `"autoplace"` | `"blueprintable"` | `"item-to-place"` | `"name"` | `"type"` | `"collision-mask"` | `"flag"` | `"build-base-evolution-requirement"` | `"selection-priority"` | `"emissions-per-second"` | `"crafting-category"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

