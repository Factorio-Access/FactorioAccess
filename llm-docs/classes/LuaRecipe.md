# LuaRecipe

A crafting recipe. Recipes belong to forces (see [LuaForce](runtime:LuaForce)) because some recipes are unlocked by research, and researches are per-force.

## Methods

### has_category

Checks if recipe has given category

**Parameters:**

- `category` `RecipeCategoryID`: 

**Returns:**

- `boolean`: `true` if recipe has this category.

### reload

Reload the recipe from the prototype.

## Attributes

### additional_categories

**Type:** ``string`[]` _(read-only)_

Additional categories of this recipe.

### category

**Type:** `string` _(read-only)_

Category of the recipe.

### enabled

**Type:** `boolean`

Can the recipe be used?

### energy

**Type:** `double` _(read-only)_

Energy required to execute this recipe. This directly affects the crafting time: Recipe's energy is exactly its crafting time in seconds, when crafted in an assembling machine with crafting speed exactly equal to one.

### force

**Type:** `LuaForce` _(read-only)_

The force that owns this recipe.

### group

**Type:** `LuaGroup` _(read-only)_

Group of this recipe.

### hidden

**Type:** `boolean` _(read-only)_

Is the recipe hidden? Hidden recipes don't show up in the crafting menu.

### hidden_from_flow_stats

**Type:** `boolean`

Is the recipe hidden from flow statistics?

### ingredients

**Type:** ``Ingredient`[]` _(read-only)_

The ingredients to this recipe.

### localised_description

**Type:** `LocalisedString` _(read-only)_



### localised_name

**Type:** `LocalisedString` _(read-only)_

Localised name of the recipe.

### name

**Type:** `string` _(read-only)_

Name of the recipe. This can be different than the name of the result items as there could be more recipes to make the same item.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### order

**Type:** `string` _(read-only)_

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

### productivity_bonus

**Type:** `float`

The productivity bonus for this recipe.

### products

**Type:** ``Product`[]` _(read-only)_

The results/products of this recipe.

### prototype

**Type:** `LuaRecipePrototype` _(read-only)_

The prototype for this recipe.

### subgroup

**Type:** `LuaGroup` _(read-only)_

Subgroup of this recipe.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

