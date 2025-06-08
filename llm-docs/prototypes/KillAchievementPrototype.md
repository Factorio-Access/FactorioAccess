# KillAchievementPrototype

This prototype is used for receiving an achievement when the player destroys a certain amount of an entity, with a specific damage type.

**Parent:** `AchievementPrototype`

## Properties

### Optional Properties

#### amount

**Type:** `uint32`

This is the amount of entity of the specified type the player needs to destroy to receive the achievement.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### damage_dealer

**Type:** 

The killer of the entity must be one of these entities.

#### damage_type

**Type:** `DamageTypeID`

This defines how the player needs to destroy the specific entity.

#### in_vehicle

**Type:** `boolean`

This defines if the player needs to be in a vehicle.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### personally

**Type:** `boolean`

This defines to make sure you are the one driving, for instance, in a tank rather than an automated train.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### to_kill

**Type:** 

This defines which entity needs to be destroyed in order to receive the achievement.

#### type_to_kill

**Type:** `string`

This defines what entity type needs to be destroyed in order to receive the achievement.

