# ShootAchievementPrototype

This prototype is used for receiving an achievement when the player shoots certain ammo.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `shoot-achievement`

## Properties

### ammo_type

This will trigger the achievement, if this ammo is shot.

**Type:** `ItemID`

**Optional:** Yes

**Examples:**

```
ammo_type = "atomic-bomb"
```

### amount

How much of the ammo needs to be shot.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

