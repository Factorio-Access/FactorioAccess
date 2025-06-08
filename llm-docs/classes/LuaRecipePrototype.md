# LuaRecipePrototype

A crafting recipe prototype.

**Parent:** `LuaPrototypeBase`

## Methods

### has_category

Checks if recipe has given category

**Parameters:**

- `category` `RecipeCategoryID`: 

**Returns:**

- `boolean`: `true` if recipe has this category.

## Attributes

### additional_categories

**Type:** ``string`[]` _(read-only)_

Additional categories of the recipe.

### allow_as_intermediate

**Type:** `boolean` _(read-only)_

If this recipe is enabled for the purpose of intermediate hand-crafting.

### allow_decomposition

**Type:** `boolean` _(read-only)_

Is this recipe allowed to be broken down for the recipe tooltip "Total raw" calculations?

### allow_inserter_overload

**Type:** `boolean` _(read-only)_

If the recipe is allowed to have the extra inserter overload bonus applied (4 * stack inserter stack size).

### allow_intermediates

**Type:** `boolean` _(read-only)_

If this recipe is allowed to use intermediate recipes when hand-crafting.

### allowed_effects

**Type:** `dictionary<`string`, `boolean`>` _(read-only)_

The allowed module effects for this recipe, if any.

### allowed_module_categories

**Type:** `dictionary<`string`, `True`>` _(read-only)_

The allowed module categories for this recipe, if any.

### alternative_unlock_methods

**Type:** ``LuaTechnologyPrototype`[]` _(read-only)_

Additional technologies listed under "Unlocked by" on a recipe's Factoriopedia page.

### always_show_made_in

**Type:** `boolean` _(read-only)_

Should this recipe always show "Made in" in the tooltip?

### always_show_products

**Type:** `boolean` _(read-only)_

If the products are always shown in the recipe tooltip.

### category

**Type:** `string` _(read-only)_

Category of the recipe.

### crafting_machine_tints

**Type:** ``Color`[]` _(read-only)_



### effect_limitation_messages

**Type:** ``LocalisedString`[]` _(read-only)_



### emissions_multiplier

**Type:** `double` _(read-only)_

The emissions multiplier for this recipe.

### enabled

**Type:** `boolean` _(read-only)_

If this recipe prototype is enabled by default (enabled at the beginning of a game).

### energy

**Type:** `double` _(read-only)_

Energy required to execute this recipe. This directly affects the crafting time: Recipe's energy is exactly its crafting time in seconds, when crafted in an assembling machine with crafting speed exactly equal to one.

### factoriopedia_alternative

**Type:** `LuaRecipePrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### hidden_from_flow_stats

**Type:** `boolean` _(read-only)_

Is the recipe hidden from flow statistics (item/fluid production statistics)?

### hidden_from_player_crafting

**Type:** `boolean` _(read-only)_

Is the recipe hidden from player crafting? The recipe will still show up for selection in machines.

### hide_from_flow_stats

**Type:** `boolean` _(read-only)_



### hide_from_player_crafting

**Type:** `boolean` _(read-only)_



### hide_from_signal_gui

**Type:** `boolean` _(read-only)_

Is this recipe is marked to be hidden from the signal GUI.

### ingredients

**Type:** ``Ingredient`[]` _(read-only)_

The ingredients to this recipe.

### is_parameter

**Type:** `boolean` _(read-only)_



### main_product

**Type:** `Product` _(read-only)_

The main product of this recipe, if any.

### maximum_productivity

**Type:** `double` _(read-only)_

The maximal productivity bonus that can be achieved with this recipe.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### overload_multiplier

**Type:** `uint` _(read-only)_

Used to determine how many extra items are put into an assembling machine before it's considered "full enough".

### preserve_products_in_machine_output

**Type:** `boolean` _(read-only)_



### products

**Type:** ``Product`[]` _(read-only)_

The results/products of this recipe.

### request_paste_multiplier

**Type:** `uint` _(read-only)_

The multiplier used when this recipe is copied from an assembling machine to a requester chest. For each item in the recipe the item count * this value is set in the requester chest.

### reset_freshness_on_craft

**Type:** `boolean` _(read-only)_



### result_is_always_fresh

**Type:** `boolean` _(read-only)_



### show_amount_in_title

**Type:** `boolean` _(read-only)_

If the amount is shown in the recipe tooltip title when the recipe produces more than 1 product.

### surface_conditions

**Type:** ``SurfaceCondition`[]` _(read-only)_

The surface conditions required to craft this recipe.

### trash

**Type:** ``LuaItemPrototype`[]` _(read-only)_

The 'trash' items that this recipe might produce as a result of spoiling.

### unlock_results

**Type:** `boolean` _(read-only)_

Is this recipe unlocks the result item(s) so they're shown in filter-select GUIs.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

