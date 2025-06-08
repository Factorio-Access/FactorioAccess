# ProducePerHourAchievementPrototype

This prototype is used for receiving an achievement when the player crafts a specified item a certain amount, in an hour.

**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### amount

**Type:** `MaterialAmountType`

This is how much the player has to craft in an hour, to receive the achievement.

### Optional Properties

#### fluid_product

**Type:** `FluidID`

Mandatory if `item_product` is not defined.

This will tell the achievement what fluid the player needs to craft, to get the achievement.

#### item_product

**Type:** `ItemIDFilter`

Mandatory if `fluid_product` is not defined.

This will tell the achievement what item the player needs to craft, to get the achievement.

