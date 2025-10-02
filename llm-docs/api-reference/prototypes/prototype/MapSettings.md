# MapSettings

The default map settings.

**Type name:** `map-settings`
**Instance limit:** 1

## Properties

### type

**Type:** `"map-settings"`

**Required:** Yes

### name

Name of the map-settings. Base game uses "map-settings".

**Type:** `string`

**Required:** Yes

### pollution

**Type:** `PollutionSettings`

**Required:** Yes

### steering

**Type:** `SteeringSettings`

**Required:** Yes

### enemy_evolution

**Type:** `EnemyEvolutionSettings`

**Required:** Yes

### enemy_expansion

**Type:** `EnemyExpansionSettings`

**Required:** Yes

### unit_group

**Type:** `UnitGroupSettings`

**Required:** Yes

### path_finder

**Type:** `PathFinderSettings`

**Required:** Yes

### max_failed_behavior_count

If a behavior fails this many times, the enemy (or enemy group) is destroyed. This solves biters stuck within their own base.

**Type:** `uint32`

**Required:** Yes

### difficulty_settings

**Type:** `DifficultySettings`

**Required:** Yes

### asteroids

**Type:** `AsteroidSettings`

**Required:** Yes

