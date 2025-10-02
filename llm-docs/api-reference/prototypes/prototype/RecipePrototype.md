# RecipePrototype

A recipe. It can be a crafting recipe, a smelting recipe, or a custom type of recipe, see [RecipeCategory](prototype:RecipeCategory).

**Parent:** [Prototype](Prototype.md)
**Type name:** `recipe`

## Examples

```
{
  type = "recipe",
  name = "iron-plate",
  category = "smelting",
  energy_required = 3.5,
  ingredients = {{type = "item", name = "iron-ore", amount = 1}},
  results = {{type = "item", name = "iron-plate", amount = 1}}
}
```

```
{
  type = "recipe",
  name = "coal-liquefaction",
  category = "oil-processing",
  subgroup = "fluid-recipes",
  order = "a[oil-processing]-c[coal-liquefaction]",
  enabled = false,
  energy_required = 5,
  icon = "__base__/graphics/icons/fluid/coal-liquefaction.png",
  icon_size = 32,
  ingredients =
  {
    {type = "item", name = "coal", amount = 10},
    {type = "fluid", name = "heavy-oil", amount = 25},
    {type = "fluid", name = "steam", amount = 50}
  },
  results=
  {
    {type = "fluid", name = "heavy-oil", amount = 35},
    {type = "fluid", name = "light-oil", amount = 15},
    {type = "fluid", name = "petroleum-gas", amount = 20}
  },
  allow_decomposition = false
}
```

## Properties

### category

The [category](prototype:RecipeCategory) of this recipe. Controls which machines can craft this recipe.

The built-in categories can be found [here](https://wiki.factorio.com/Data.raw#recipe-category). The base `"crafting"` category can not contain recipes with fluid ingredients or products.

**Type:** `RecipeCategoryID`

**Optional:** Yes

**Default:** "crafting"

**Examples:**

```
category = "smelting"
```

### additional_categories

**Type:** Array[`RecipeCategoryID`]

**Optional:** Yes

### crafting_machine_tint

Used by [WorkingVisualisations::working_visualisations](prototype:WorkingVisualisations::working_visualisations) to tint certain layers with the recipe color. [WorkingVisualisation::apply_recipe_tint](prototype:WorkingVisualisation::apply_recipe_tint) determines which of the four colors is used for that layer, if any.

**Type:** `RecipeTints`

**Optional:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

If given, this determines the recipe's icon. Otherwise, the icon of `main_product` or the singular product is used.

Only loaded if `icons` is not defined.

Mandatory if `icons` is not defined for a recipe with more than one product and no `main_product`, or no product.

**Type:** `FileName`

**Optional:** Yes

**Examples:**

```
icon = "__base__/graphics/icons/fluid/heavy-oil.png"
```

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### ingredients

A table containing ingredient names and amounts. Can also contain information about fluid temperature and whether some of the amount is ignored by production statistics.

The maximum ingredient amount is 65 535. Can be set to an empty table to create a recipe that needs no ingredients.

Duplicate ingredients, e.g. two entries with the same name, are *not* allowed. In-game, the item ingredients are ordered by [ItemGroup::order_in_recipe](prototype:ItemGroup::order_in_recipe).

**Type:** Array[`IngredientPrototype`]

**Optional:** Yes

**Examples:**

```
-- Recipe with items
ingredients =
{
  {type = "item", name = "iron-stick", amount = 2},
  {type = "item", name = "iron-plate", amount = 3}
}
```

```
-- Recipe with fluids
ingredients =
{
  {type = "fluid", name = "water", amount = 50},
  {type = "fluid", name = "crude-oil", amount = 100}
}
```

### results

A table containing result names and amounts. Products also contain information such as fluid temperature, probability of results and whether some of the amount is ignored by productivity.

Can be set to an empty table to create a recipe that produces nothing. Duplicate results, e.g. two entries with the same name, are allowed.

**Type:** Array[`ProductPrototype`]

**Optional:** Yes

**Examples:**

```
results =
{
  {type = "fluid", name= "heavy-oil", amount = 3},
  {type = "fluid", name= "light-oil", amount = 3},
  {type = "fluid", name= "petroleum-gas", amount = 4}
}
```

```
results =
{
  {type = "item", name = "iron-plate", amount = 9},
  {type = "item", name = "copper-plate", amount = 1}
}
```

```
results = {{type = "fluid", name = "steam", amount = 1, temperature = 165}}
```

### main_product

For recipes with one or more products: Subgroup, localised_name and icon default to the values of the singular/main product, but can be overwritten by the recipe. Setting the main_product to an empty string (`""`) forces the title in the recipe tooltip to use the recipe's name (not that of the product) and shows the products in the tooltip.

If 1) there are multiple products and this property is nil, 2) this property is set to an empty string (`""`), or 3) there are no products, the recipe will use the localised_name, icon, and subgroup of the recipe. icon and subgroup become non-optional.

**Type:** `string`

**Optional:** Yes

### energy_required

The amount of time it takes to make this recipe. Must be `> 0.001`. Equals the number of seconds it takes to craft at crafting speed `1`.

**Type:** `double`

**Optional:** Yes

**Default:** 0.5

### emissions_multiplier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### maximum_productivity

Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 3.0

### requester_paste_multiplier

**Type:** `uint32`

**Optional:** Yes

**Default:** 30

### overload_multiplier

Used to determine how many extra items are put into an assembling machine before it's considered "full enough". See [insertion limits](https://wiki.factorio.com/Inserters#Insertion_limits).

If set to `0`, it instead uses the following formula: `1.166 / (energy_required / the assembler's crafting_speed)`, rounded up, and clamped to be between`2` and `100`. The numbers used in this formula can be changed by the [UtilityConstants](prototype:UtilityConstants) properties `dynamic_recipe_overload_factor`, `minimum_recipe_overload_multiplier`, and `maximum_recipe_overload_multiplier`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### allow_inserter_overload

Whether the recipe is allowed to have the extra inserter overload bonus applied (4 * stack inserter stack size).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### enabled

This can be `false` to disable the recipe at the start of the game, or `true` to leave it enabled.

If a recipe is unlocked via technology, this should be set to `false`.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### hide_from_stats

Hides the recipe from item/fluid production statistics.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hide_from_player_crafting

Hides the recipe from the player's crafting screen. The recipe will still show up for selection in machines.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hide_from_bonus_gui

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_decomposition

Whether this recipe is allowed to be broken down for the recipe tooltip "Total raw" calculations.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_as_intermediate

Whether the recipe can be used as an intermediate recipe in hand-crafting.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_intermediates

Whether the recipe is allowed to use intermediate recipes when hand-crafting.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### always_show_made_in

Whether the "Made in: <Machine>" part of the tool-tip should always be present, and not only when the recipe can't be hand-crafted.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### show_amount_in_title

Whether the recipe name should have the product amount in front of it. E.g. "2x Transport belt".

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### always_show_products

Whether the products are always shown in the recipe tooltip.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### unlock_results

Whether enabling this recipe unlocks its item products to show in selection lists (item filters, logistic requests, etc.).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### preserve_products_in_machine_output

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### result_is_always_fresh

When set to true, the recipe will always produce fresh (non-spoiled) item even when the ingredients are spoiled.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### reset_freshness_on_craft

When set to true, if the recipe successfully finishes crafting without spoiling, the result is produced fresh (non-spoiled).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_consumption_message

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"item-limitation.consumption-effect"}`"

### allow_speed_message

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"item-limitation.speed-effect"}`"

### allow_productivity_message

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"item-limitation.productivity-effect"}`"

### allow_pollution_message

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"item-limitation.pollution-effect"}`"

### allow_quality_message

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"item-limitation.quality-effect"}`"

### surface_conditions

**Type:** Array[`SurfaceCondition`]

**Optional:** Yes

### hide_from_signal_gui

If left unset, this property will be determined automatically: If the recipe is not `hidden`, and no item, fluid, or virtual signal has the same icon as this recipe, this property will be set to `false`. It'll be `true` otherwise.

**Type:** `boolean`

**Optional:** Yes

### allow_consumption

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_speed

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_productivity

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_pollution

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_quality

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allowed_module_categories

Sets the [module categories](prototype:ModuleCategory) that are allowed to be used with this recipe.

**Type:** Array[`ModuleCategoryID`]

**Optional:** Yes

**Default:** "All module categories are allowed"

### alternative_unlock_methods

Additional technologies to list under "Unlocked by" on a recipe's Factoriopedia page.

**Type:** Array[`TechnologyID`]

**Optional:** Yes

### auto_recycle

Whether the recipe should be included in the recycling recipes automatically generated by the quality mod.

This property is not read by the game engine itself, but the quality mod's recycling.lua file. This means it is discarded by the game engine after loading finishes.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

