# MapAndDifficultySettings

A standard table containing all [MapSettings](runtime:MapSettings) attributes plus an additional table that contains all [DifficultySettings](runtime:DifficultySettings) properties.

**Type:** Table

## Parameters

### asteroids

**Type:** `AsteroidMapSettings`

**Required:** Yes

### difficulty_settings

**Type:** `MapDifficultySettings`

**Required:** Yes

### enemy_evolution

**Type:** `EnemyEvolutionMapSettings`

**Required:** Yes

### enemy_expansion

**Type:** `EnemyExpansionMapSettings`

**Required:** Yes

### max_failed_behavior_count

If a behavior fails this many times, the enemy (or enemy group) is destroyed. This solves biters getting stuck within their own base.

**Type:** `uint`

**Required:** Yes

### path_finder

**Type:** `PathFinderMapSettings`

**Required:** Yes

### pollution

**Type:** `PollutionMapSettings`

**Required:** Yes

### steering

**Type:** `SteeringMapSettings`

**Required:** Yes

### unit_group

**Type:** `UnitGroupMapSettings`

**Required:** Yes

