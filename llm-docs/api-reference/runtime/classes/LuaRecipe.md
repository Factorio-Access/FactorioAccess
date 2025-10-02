# LuaRecipe

A crafting recipe. Recipes belong to forces (see [LuaForce](runtime:LuaForce)) because some recipes are unlocked by research, and researches are per-force.

## Attributes

### name

Name of the recipe. This can be different than the name of the result items as there could be more recipes to make the same item.

**Read type:** `string`

### localised_name

Localised name of the recipe.

**Read type:** `LocalisedString`

### localised_description

**Read type:** `LocalisedString`

### prototype

The prototype for this recipe.

**Read type:** `LuaRecipePrototype`

### enabled

Can the recipe be used?

**Read type:** `boolean`

**Write type:** `boolean`

### category

Category of the recipe.

**Read type:** `string`

### additional_categories

Additional categories of this recipe.

**Read type:** Array[`string`]

### ingredients

The ingredients to this recipe.

**Read type:** Array[`Ingredient`]

### products

The results/products of this recipe.

**Read type:** Array[`Product`]

### hidden

Is the recipe hidden? Hidden recipes don't show up in the crafting menu.

**Read type:** `boolean`

### hidden_from_flow_stats

Is the recipe hidden from flow statistics?

**Read type:** `boolean`

**Write type:** `boolean`

### energy

Energy required to execute this recipe. This directly affects the crafting time: Recipe's energy is exactly its crafting time in seconds, when crafted in an assembling machine with crafting speed exactly equal to one.

**Read type:** `double`

### order

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

**Read type:** `string`

### group

Group of this recipe.

**Read type:** `LuaGroup`

### subgroup

Subgroup of this recipe.

**Read type:** `LuaGroup`

### force

The force that owns this recipe.

**Read type:** `LuaForce`

### productivity_bonus

The productivity bonus for this recipe.

**Read type:** `float`

**Write type:** `float`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### reload

Reload the recipe from the prototype.

### has_category

Checks if recipe has given category

**Parameters:**

- `category` `RecipeCategoryID`

**Returns:**

- `boolean` - `true` if recipe has this category.

