# UnitSpawnDefinition

It can be specified as a table with named or numbered keys, but not a mix of both. If this is specified as a table with numbered keys then the first value is the unit and the second is the spawn points.

**Type:** `Struct` (see below for attributes) | (`EntityID`, Array[`SpawnPoint`])

## Properties

*These properties apply when the value is a struct/table.*

### unit

**Type:** `EntityID`

**Required:** Yes

### spawn_points

Array of evolution and probability info, with the following conditions:

- The `evolution_factor` must be ascending from entry to entry.

- The last entry's weight will be used when the `evolution_factor` is larger than the last entry.

- Weights are linearly interpolated between entries.

- Individual weights are scaled linearly so that the cumulative weight is `1`.

**Type:** Array[`SpawnPoint`]

**Required:** Yes

