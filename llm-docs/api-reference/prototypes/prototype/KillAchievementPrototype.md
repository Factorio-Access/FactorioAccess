# KillAchievementPrototype

This prototype is used for receiving an achievement when the player destroys a certain amount of an entity, with a specific damage type.

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `kill-achievement`

## Properties

### to_kill

This defines which entity needs to be destroyed in order to receive the achievement.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### type_to_kill

This defines what entity type needs to be destroyed in order to receive the achievement.

**Type:** `string`

**Optional:** Yes

**Examples:**

```
type_to_kill = "inserter"
```

### damage_type

This defines how the player needs to destroy the specific entity.

**Type:** `DamageTypeID`

**Optional:** Yes

**Examples:**

```
damage_type = "impact"
```

### damage_dealer

The killer of the entity must be one of these entities.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

**Examples:**

```
damage_dealer = "artillery-turret"
```

```
damage_dealer = {"artillery-turret", "artillery-wagon"}
```

### amount

This is the amount of entity of the specified type the player needs to destroy to receive the achievement.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

**Examples:**

```
amount = 100
```

### in_vehicle

This defines if the player needs to be in a vehicle.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Examples:**

```
in_vehicle = true
```

### personally

This defines to make sure you are the one driving, for instance, in a tank rather than an automated train.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Examples:**

```
personally = true
```

