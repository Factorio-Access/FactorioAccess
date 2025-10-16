# ItemProductPrototype

An item product definition.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"item"`

**Required:** Yes

### name

The name of an [ItemPrototype](prototype:ItemPrototype).

**Type:** `ItemID`

**Required:** Yes

### amount

**Type:** `uint16`

**Optional:** Yes

### amount_min

Only loaded, and mandatory if `amount` is not defined.

**Type:** `uint16`

**Optional:** Yes

### amount_max

Only loaded, and mandatory if `amount` is not defined.

If set to a number that is less than `amount_min`, the game will use `amount_min` instead.

**Type:** `uint16`

**Optional:** Yes

### probability

Value between 0 and 1, `0` for 0% chance and `1` for 100% chance.

The effect of probability is no product, or a linear distribution on [min, max]. For a recipe with probability `p`, amount_min `min`, and amount_max `max`, the Expected Value of this product can be expressed as `p * (0.5 * (max + min))`. This is what will be shown in a recipe tooltip. The effect of `ignored_by_productivity` on the product is not shown.

When `amount_min` and `amount_max` are not provided, `amount` applies as min and max. The Expected Value simplifies to `p * amount`, providing `0` product, or `amount` product, on recipe completion.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### ignored_by_stats

Amount that should not be included in the item production statistics, typically with a matching ingredient having the same amount set as [ignored_by_stats](prototype:ItemIngredientPrototype::ignored_by_stats).

If `ignored_by_stats` is larger than the amount crafted (for instance due to probability) it will instead show as consumed.

Products with `ignored_by_stats` defined will not be set as recipe through the circuit network when using the product's item-signal.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### ignored_by_productivity

Amount that should be deducted from any productivity induced bonus crafts.

This value can safely be set larger than the maximum expected craft amount, any excess is ignored.

This value is ignored when [allow_productivity](prototype:RecipePrototype::allow_productivity) is `false`.

**Type:** `uint16`

**Optional:** Yes

**Default:** "Value of `ignored_by_stats`"

### show_details_in_recipe_tooltip

When hovering over a recipe in the crafting menu the recipe tooltip will be shown. An additional item tooltip will be shown for every product, as a separate tooltip, if the item tooltip has a description and/or properties to show and if `show_details_in_recipe_tooltip` is `true`.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### extra_count_fraction

Probability that a craft will yield one additional product. Also applies to bonus crafts caused by productivity.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### percent_spoiled

Must be >= `0` and < `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

