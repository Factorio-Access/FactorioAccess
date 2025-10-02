# LuaRecipePrototype

A crafting recipe prototype.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### enabled

If this recipe prototype is enabled by default (enabled at the beginning of a game).

**Read type:** `boolean`

### category

Category of the recipe.

**Read type:** `string`

### additional_categories

Additional categories of the recipe.

**Read type:** Array[`string`]

### ingredients

The ingredients to this recipe.

**Read type:** Array[`Ingredient`]

### products

The results/products of this recipe.

**Read type:** Array[`Product`]

### main_product

The main product of this recipe, if any.

**Read type:** `Product`

**Optional:** Yes

### hidden_from_flow_stats

Is the recipe hidden from flow statistics (item/fluid production statistics)?

**Read type:** `boolean`

### hidden_from_player_crafting

Is the recipe hidden from player crafting? The recipe will still show up for selection in machines.

**Read type:** `boolean`

### always_show_made_in

Should this recipe always show "Made in" in the tooltip?

**Read type:** `boolean`

### energy

Energy required to execute this recipe. This directly affects the crafting time: Recipe's energy is exactly its crafting time in seconds, when crafted in an assembling machine with crafting speed exactly equal to one.

**Read type:** `double`

### request_paste_multiplier

The multiplier used when this recipe is copied from an assembling machine to a requester chest. For each item in the recipe the item count * this value is set in the requester chest.

**Read type:** `uint`

### overload_multiplier

Used to determine how many extra items are put into an assembling machine before it's considered "full enough".

**Read type:** `uint`

### maximum_productivity

The maximal productivity bonus that can be achieved with this recipe.

**Read type:** `double`

### allow_inserter_overload

If the recipe is allowed to have the extra inserter overload bonus applied (4 * stack inserter stack size).

**Read type:** `boolean`

### allow_as_intermediate

If this recipe is enabled for the purpose of intermediate hand-crafting.

**Read type:** `boolean`

### allow_intermediates

If this recipe is allowed to use intermediate recipes when hand-crafting.

**Read type:** `boolean`

### show_amount_in_title

If the amount is shown in the recipe tooltip title when the recipe produces more than 1 product.

**Read type:** `boolean`

### always_show_products

If the products are always shown in the recipe tooltip.

**Read type:** `boolean`

### emissions_multiplier

The emissions multiplier for this recipe.

**Read type:** `double`

### allow_decomposition

Is this recipe allowed to be broken down for the recipe tooltip "Total raw" calculations?

**Read type:** `boolean`

### unlock_results

Is this recipe unlocks the result item(s) so they're shown in filter-select GUIs.

**Read type:** `boolean`

### hide_from_signal_gui

Is this recipe is marked to be hidden from the signal GUI.

**Read type:** `boolean`

### hide_from_flow_stats

**Read type:** `boolean`

### hide_from_player_crafting

**Read type:** `boolean`

### hide_from_bonus_gui

**Read type:** `boolean`

### trash

The 'trash' items that this recipe might produce as a result of spoiling.

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

### preserve_products_in_machine_output

**Read type:** `boolean`

### is_parameter

**Read type:** `boolean`

### allowed_effects

The allowed module effects for this recipe, if any.

**Read type:** Dictionary[`string`, `boolean`]

**Optional:** Yes

### allowed_module_categories

The allowed module categories for this recipe, if any.

**Read type:** Dictionary[`string`, `True`]

**Optional:** Yes

### effect_limitation_messages

**Read type:** Array[`LocalisedString`]

**Optional:** Yes

### surface_conditions

The surface conditions required to craft this recipe.

**Read type:** Array[`SurfaceCondition`]

**Optional:** Yes

### alternative_unlock_methods

Additional technologies listed under "Unlocked by" on a recipe's Factoriopedia page.

**Read type:** Array[`LuaTechnologyPrototype`]

**Optional:** Yes

### crafting_machine_tints

**Read type:** Array[`Color`]

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaRecipePrototype`

**Optional:** Yes

### result_is_always_fresh

**Read type:** `boolean`

### reset_freshness_on_craft

**Read type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### has_category

Checks if recipe has given category

**Parameters:**

- `category` `RecipeCategoryID`

**Returns:**

- `boolean` - `true` if recipe has this category.

