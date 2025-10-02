# PlayerDamagedAchievementPrototype

This prototype is used for receiving an achievement when the player receives damage.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `player-damaged-achievement`

## Properties

### minimum_damage

This will trigger the achievement, if the amount of damage taken by the dealer, is more than this.

**Type:** `float`

**Required:** Yes

**Examples:**

```
minimum_damage = 500
```

### should_survive

This sets the achievement to only trigger, if you survive the minimum amount of damage. If you don't need to survive, false.

**Type:** `boolean`

**Required:** Yes

**Examples:**

```
should_survive = true
```

### type_of_dealer

This will trigger the achievement, if the player takes damage from this specific entity type.

**Type:** `string`

**Optional:** Yes

**Default:** ""

**Examples:**

```
type_of_dealer = "locomotive"
```

