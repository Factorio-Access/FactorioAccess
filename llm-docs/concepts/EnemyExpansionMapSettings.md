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

