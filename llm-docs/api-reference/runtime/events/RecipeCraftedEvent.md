# RecipeCraftedEvent

Called when a recipe with [RecipePrototype::raise_on_crafted](prototype:RecipePrototype::raise_on_crafted) is crafted.

## Event Data

### bonus

**Type:** `boolean`

If crafted as part of bonus products.

### entity

**Type:** `LuaEntity`

Entity that crafted recipe.

### name

**Type:** `defines.events`

Identifier of the event.

### product_quality

**Type:** `string`

Quality of products given. May be different than recipe quality if quality modules are present. Always provided even if quality_effect is zero because [LuaEntity::result_quality](runtime:LuaEntity::result_quality) may have been used. Only used by products without quality control.

### quality_effect

**Type:** `EffectValue` *(optional)*

Quality effect used when giving products. Not provided if value is 0. May be different than value obtained from [LuaEntity::effects](runtime:LuaEntity::effects) when quality modules were changed between craft starting and products being given.

### quality_seed

**Type:** `double` *(optional)*

Random value in range [0, 1) that was used when selecting product quality. Only provided when quality_effect is provided.

### recipe

**Type:** `string`

Name of recipe that was crafted.

### recipe_quality

**Type:** `string`

Quality of the recipe crafted.

### shared_roll

**Type:** `double`

Random value in range [0, 1) used as part of shared roll when giving products. Related to [ProductPrototypeBase::shared_probability](prototype:ProductPrototypeBase::shared_probability).

### tick

**Type:** `MapTick`

Tick the event was generated.

