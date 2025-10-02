# SpawnPoint

The definition of a evolution and probability weights for a [spawnable unit](prototype:UnitSpawnDefinition) for a [EnemySpawnerPrototype](prototype:EnemySpawnerPrototype).

It can be specified as a table with named or numbered keys, but not a mix of both. If this is specified as a table with numbered keys then the first value is the evolution factor and the second is the spawn weight.

**Type:** `Struct` (see below for attributes) | (`double`, `double`)

## Properties

*These properties apply when the value is a struct/table.*

### evolution_factor

**Type:** `double`

**Required:** Yes

### spawn_weight

Must be `>= 0`.

**Type:** `double`

**Required:** Yes

