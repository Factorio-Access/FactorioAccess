# RecipePrototypeFilter

**Type:** Table

## Parameters

### filter

The condition to filter on.

**Type:** `"enabled"` | `"hidden"` | `"hidden-from-flow-stats"` | `"hidden-from-player-crafting"` | `"allow-as-intermediate"` | `"allow-intermediates"` | `"allow-decomposition"` | `"always-show-made-in"` | `"always-show-products"` | `"show-amount-in-title"` | `"has-ingredients"` | `"has-products"` | `"has-ingredient-item"` | `"has-ingredient-fluid"` | `"has-product-item"` | `"has-product-fluid"` | `"subgroup"` | `"category"` | `"energy"` | `"emissions-multiplier"` | `"request-paste-multiplier"` | `"overload-multiplier"`

**Required:** Yes

### invert

Inverts the condition. Default is `false`.

**Type:** `boolean`

**Optional:** Yes

### mode

How to combine this with the previous filter. Defaults to `"or"`. When evaluating the filters, `"and"` has higher precedence than `"or"`.

**Type:** `"or"` | `"and"`

**Optional:** Yes

