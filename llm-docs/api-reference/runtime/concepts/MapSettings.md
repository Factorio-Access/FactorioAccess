# MapSettings

Various game-related settings. Updating any of the attributes will immediately take effect in the game engine.

**Type:** `Struct`

## Attributes

### asteroids

**Read type:** `AsteroidMapSettings`

**Write type:** `AsteroidMapSettings`

### enemy_evolution

**Read type:** `EnemyEvolutionMapSettings`

**Write type:** `EnemyEvolutionMapSettings`

### enemy_expansion

**Read type:** `EnemyExpansionMapSettings`

**Write type:** `EnemyExpansionMapSettings`

### max_failed_behavior_count

If a behavior fails this many times, the enemy (or enemy group) is destroyed. This solves biters getting stuck within their own base.

**Read type:** `uint`

**Write type:** `uint`

### path_finder

**Read type:** `PathFinderMapSettings`

**Write type:** `PathFinderMapSettings`

### pollution

**Read type:** `PollutionMapSettings`

**Write type:** `PollutionMapSettings`

### steering

**Read type:** `SteeringMapSetting`

**Write type:** `SteeringMapSetting`

### unit_group

**Read type:** `UnitGroupMapSettings`

**Write type:** `UnitGroupMapSettings`

## Examples

```
```
-- Increase the number of short paths the pathfinder can cache.
game.map_settings.path_finder.short_cache_size = 15
```
```

