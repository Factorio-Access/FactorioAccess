# ItemPrototypeFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"tool"` | `"mergeable"` | `"hidden"` | `"hidden-in-factoriopedia"` | `"is-parameter"` | `"item-with-inventory"` | `"selection-tool"` | `"item-with-label"` | `"has-rocket-launch-products"` | `"fuel"` | `"place-result"` | `"burnt-result"` | `"place-as-tile"` | `"placed-as-equipment-result"` | `"plant-result"` | `"spoil-result"` | `"name"` | `"type"` | `"flag"` | `"subgroup"` | `"fuel-category"` | `"stack-size"` | `"fuel-value"` | `"fuel-acceleration-multiplier"` | `"fuel-top-speed-multiplier"` | `"fuel-emissions-multiplier"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

