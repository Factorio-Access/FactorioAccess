# ProducePerHourAchievementPrototype

This prototype is used for receiving an achievement when the player crafts a specified item a certain amount, in an hour.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `produce-per-hour-achievement`

## Properties

### amount

This is how much the player has to craft in an hour, to receive the achievement.

**Type:** `MaterialAmountType`

**Required:** Yes

**Examples:**

```
amount = 1000
```

### item_product

Mandatory if `fluid_product` is not defined.

This will tell the achievement what item the player needs to craft, to get the achievement.

**Type:** `ItemIDFilter`

**Optional:** Yes

**Examples:**

```
item_product = "landfill"
```

### fluid_product

Mandatory if `item_product` is not defined.

This will tell the achievement what fluid the player needs to craft, to get the achievement.

**Type:** `FluidID`

**Optional:** Yes

**Examples:**

```
fluid_product = "light-oil"
```

