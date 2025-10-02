# SpaceConnectionDistanceTraveledAchievementPrototype

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Type name:** `space-connection-distance-traveled-achievement`

## Properties

### tracked_connection

**Type:** `SpaceConnectionID`

**Required:** Yes

### distance

How far a platform must travel to gain this achievement. Repeated trips over a shorter distance do not count.

**Type:** `uint32`

**Required:** Yes

### reversed

The achievement is unidirectional, this property controls the direction (using space connection definition).

When false, a platform must go through [from](prototype:SpaceConnectionPrototype::from) location and travel in [to](prototype:SpaceConnectionPrototype::to) direction. When true, a platform must go through `to` location and travel in `from` direction.

**Type:** `boolean`

**Required:** Yes

