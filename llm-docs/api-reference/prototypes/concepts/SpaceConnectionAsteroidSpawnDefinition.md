# SpaceConnectionAsteroidSpawnDefinition

**Type:** `Struct` (see below for attributes) | (`EntityID`, Array[`SpaceConnectionAsteroidSpawnPoint`])

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"entity"` | `"asteroid-chunk"`

**Optional:** Yes

**Default:** "entity"

### asteroid

The type this is loaded as depends on `type`.

**Type:** `EntityID` | `AsteroidChunkID`

**Required:** Yes

### spawn_points

**Type:** Array[`SpaceConnectionAsteroidSpawnPoint`]

**Required:** Yes

