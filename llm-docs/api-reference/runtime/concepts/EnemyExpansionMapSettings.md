# EnemyExpansionMapSettings

Candidate chunks are given scores to determine which one of them should be expanded into. This score takes into account various settings noted below. The iteration is over a square region centered around the chunk for which the calculation is done, and includes the central chunk as well. Distances are calculated as [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry).

The pseudocode algorithm to determine a chunk's score is as follows:

```
player = 0
for neighbour in all chunks within enemy_building_influence_radius from chunk:
  player += number of player buildings on neighbour
    * building_coefficient
    * neighbouring_chunk_coefficient^distance(chunk, neighbour)
base = 0
for neighbour in all chunk within friendly_base_influence_radius from chunk:
  base += num of enemy bases on neighbour
    * other_base_coefficient
    * neighbouring_base_chunk_coefficient^distance(chunk, neighbour)
score(chunk) = 1 / (1 + player + base)
```

**Type:** Table

## Parameters

### building_coefficient

Defaults to `0.1`.

**Type:** `double`

**Required:** Yes

### enabled

Whether enemy expansion is enabled at all.

**Type:** `boolean`

**Required:** Yes

### enemy_building_influence_radius

Defaults to `2`.

**Type:** `uint32`

**Required:** Yes

### friendly_base_influence_radius

Defaults to `2`.

**Type:** `uint32`

**Required:** Yes

### max_colliding_tiles_coefficient

A chunk has to have at most this high of a percentage of unbuildable tiles for it to be considered a candidate to avoid chunks full of water as candidates. Defaults to `0.9`, or 90%.

**Type:** `double`

**Required:** Yes

### max_expansion_cooldown

The maximum time between expansions in ticks. The actual cooldown is adjusted to the current evolution levels. Defaults to `60*3 600=216 000` ticks.

**Type:** `uint32`

**Required:** Yes

### max_expansion_distance

Distance in chunks from the furthest base around to prevent expansions from reaching too far into the player's territory. Defaults to `7`.

**Type:** `uint32`

**Required:** Yes

### min_expansion_cooldown

The minimum time between expansions in ticks. The actual cooldown is adjusted to the current evolution levels. Defaults to `4*3 600=14 400` ticks.

**Type:** `uint32`

**Required:** Yes

### neighbouring_base_chunk_coefficient

Defaults to `0.4`.

**Type:** `double`

**Required:** Yes

### neighbouring_chunk_coefficient

Defaults to `0.5`.

**Type:** `double`

**Required:** Yes

### other_base_coefficient

Defaults to `2.0`.

**Type:** `double`

**Required:** Yes

### settler_group_max_size

The maximum size of a biter group that goes to build a new base. This is multiplied by the evolution factor. Defaults to `20`.

**Type:** `uint32`

**Required:** Yes

### settler_group_min_size

The minimum size of a biter group that goes to build a new base. This is multiplied by the evolution factor. Defaults to `5`.

**Type:** `uint32`

**Required:** Yes

