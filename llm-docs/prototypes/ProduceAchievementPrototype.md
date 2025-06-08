# ProduceAchievementPrototype

This prototype is used for receiving an achievement when the player produces more than the specified amount of items.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### amount

**Type:** `MaterialAmountType`

This will set the amount of items or fluids needed to craft, for the player to complete the achievement.

#### limited_to_one_game

**Type:** `boolean`

If this is false, the player carries over their statistics from this achievement through all their saves.

### Optional Properties

#### fluid_product

**Type:** `FluidID`

Mandatory if `item_product` is not defined.

This will tell the achievement what fluid the player needs to craft, to get the achievement.

#### item_product

**Type:** `ItemIDFilter`

Mandatory if `fluid_product` is not defined.

This will tell the achievement what item the player needs to craft, to get the achievement.

