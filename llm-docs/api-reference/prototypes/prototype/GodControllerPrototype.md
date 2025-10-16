# GodControllerPrototype

Properties of the god controller.

**Type name:** `god-controller`
**Instance limit:** 1

## Properties

### type

**Type:** `"god-controller"`

**Required:** Yes

### name

Name of the god-controller. Base game uses "default".

**Type:** `string`

**Required:** Yes

### inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### movement_speed

Must be >= 0.34375.

**Type:** `double`

**Required:** Yes

### item_pickup_distance

**Type:** `double`

**Required:** Yes

### loot_pickup_distance

**Type:** `double`

**Required:** Yes

### mining_speed

**Type:** `double`

**Required:** Yes

### crafting_categories

Names of the crafting categories the player can craft recipes from.

**Type:** Array[`RecipeCategoryID`]

**Optional:** Yes

### mining_categories

Names of the resource categories the player can mine resources from.

**Type:** Array[`ResourceCategoryID`]

**Optional:** Yes

