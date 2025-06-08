# SpaceConnectionDistanceTraveledAchievementPrototype



**Parent:** `AchievementPrototype`

## Properties

### Mandatory Properties

#### distance

**Type:** `uint32`

How far a platform must travel to gain this achievement. Repeated trips over a shorter distance do not count.

#### reversed

**Type:** `boolean`

The achievement is unidirectional, this property controls the direction (using space connection definition).

When false, a platform must go through [from](prototype:SpaceConnectionPrototype::from) location and travel in [to](prototype:SpaceConnectionPrototype::to) direction. When true, a platform must go through `to` location and travel in `from` direction.

#### tracked_connection

**Type:** `SpaceConnectionID`



