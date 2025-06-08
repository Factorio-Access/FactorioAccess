# GodControllerPrototype

Properties of the god controller.

## Properties

### Mandatory Properties

#### inventory_size

**Type:** `ItemStackIndex`



#### item_pickup_distance

**Type:** `double`



#### loot_pickup_distance

**Type:** `double`



#### mining_speed

**Type:** `double`



#### movement_speed

**Type:** `double`

Must be >= 0.34375.

#### name

**Type:** `string`

Name of the god-controller. Base game uses "default".

#### type

**Type:** `god-controller`



### Optional Properties

#### crafting_categories

**Type:** ``RecipeCategoryID`[]`

Names of the crafting categories the player can craft recipes from.

#### mining_categories

**Type:** ``ResourceCategoryID`[]`

Names of the resource categories the player can mine resources from.

