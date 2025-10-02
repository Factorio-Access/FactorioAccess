# PathFinderMapSettings

**Type:** Table

## Parameters

### cache_accept_path_end_distance_ratio

When looking for a path from cache, make sure it doesn't end too far from the requested end in relative terms. This is typically more lenient than the start ratio since the end target could be moving. Defaults to `0.15`.

**Type:** `double`

**Required:** Yes

### cache_accept_path_start_distance_ratio

When looking for a path from cache, make sure it doesn't start too far from the requested start in relative terms. Defaults to `0.2`.

**Type:** `double`

**Required:** Yes

### cache_max_connect_to_cache_steps_multiplier

When looking for a connection to a cached path, search at most for this number of steps times the original estimate. Defaults to `100`.

**Type:** `uint`

**Required:** Yes

### cache_path_end_distance_rating_multiplier

When assigning a rating to the best path, this multiplier times end distances is considered. This value is typically higher than the start multiplier as this results in better end path quality. Defaults to `20`.

**Type:** `double`

**Required:** Yes

### cache_path_start_distance_rating_multiplier

When assigning a rating to the best path, this multiplier times start distances is considered. Defaults to `10`.

**Type:** `double`

**Required:** Yes

### direct_distance_to_consider_short_request

The maximum direct distance in tiles before a request is no longer considered short. Defaults to `100`.

**Type:** `uint`

**Required:** Yes

### enemy_with_different_destination_collision_penalty

A penalty that is applied for another unit that is too close and either not moving or has a different goal. Defaults to `30`.

**Type:** `double`

**Required:** Yes

### extended_collision_penalty

The collision penalty for collisions in the extended bounding box but outside the entity's actual bounding box. Defaults to `3`.

**Type:** `double`

**Required:** Yes

### fwd2bwd_ratio

The pathfinder performs a step of the backward search every `fwd2bwd_ratio`'th step. The minimum allowed value is `2`, which means symmetric search. The default value is `5`.

**Type:** `uint`

**Required:** Yes

### general_entity_collision_penalty

The general collision penalty with other units. Defaults to `10`.

**Type:** `double`

**Required:** Yes

### general_entity_subsequent_collision_penalty

The collision penalty for positions that require the destruction of an entity to get to. Defaults to `3`.

**Type:** `double`

**Required:** Yes

### goal_pressure_ratio

When looking at which node to check next, their heuristic value is multiplied by this ratio. The higher it is, the more the search is directed straight at the goal. Defaults to `2`.

**Type:** `double`

**Required:** Yes

### ignore_moving_enemy_collision_distance

The distance in tiles after which other moving units are not considered for pathfinding. Defaults to `5`.

**Type:** `double`

**Required:** Yes

### long_cache_min_cacheable_distance

The minimal distance to the goal in tiles required to be searched in the long path cache. Defaults to `30`.

**Type:** `double`

**Required:** Yes

### long_cache_size

Number of elements in the long cache. Defaults to `25`.

**Type:** `uint`

**Required:** Yes

### max_clients_to_accept_any_new_request

The amount of path finder requests accepted per tick regardless of the requested path's length. Defaults to `10`.

**Type:** `uint`

**Required:** Yes

### max_clients_to_accept_short_new_request

When the `max_clients_to_accept_any_new_request` amount is exhausted, only path finder requests with a short estimate will be accepted until this amount (per tick) is reached. Defaults to `100`.

**Type:** `uint`

**Required:** Yes

### max_steps_worked_per_tick

The maximum number of nodes that are expanded per tick. Defaults to `1 000`.

**Type:** `double`

**Required:** Yes

### max_work_done_per_tick

The maximum amount of work each pathfinding job is allowed to do per tick. Defaults to `8 000`.

**Type:** `uint`

**Required:** Yes

### min_steps_to_check_path_find_termination

The minimum amount of steps that are guaranteed to be performed for every request. Defaults to `2000`.

**Type:** `uint`

**Required:** Yes

### negative_cache_accept_path_end_distance_ratio

Same principle as `cache_accept_path_end_distance_ratio`, but used for negative cache queries. Defaults to `0.3`.

**Type:** `double`

**Required:** Yes

### negative_cache_accept_path_start_distance_ratio

Same principle as `cache_accept_path_start_distance_ratio`, but used for negative cache queries. Defaults to `0.3`.

**Type:** `double`

**Required:** Yes

### negative_path_cache_delay_interval

The delay in ticks between decrementing the score of all paths in the negative cache by one. Defaults to `20`.

**Type:** `uint`

**Required:** Yes

### overload_levels

The thresholds of waiting clients after each of which the per-tick work limit will be increased by the corresponding value in `overload_multipliers`. This is to avoid clients having to wait too long. Must have the same number of elements as `overload_multipliers`. Defaults to `{0, 100, 500}`.

**Type:** Array[`uint`]

**Required:** Yes

### overload_multipliers

The multipliers to the amount of per-tick work applied after the corresponding thresholds in `overload_levels` have been reached. Must have the same number of elements as `overload_multipliers`. Defaults to `{2, 3, 4}`.

**Type:** Array[`double`]

**Required:** Yes

### short_cache_min_algo_steps_to_cache

The minimal number of nodes required to be searched in the short path cache. Defaults to `50`.

**Type:** `uint`

**Required:** Yes

### short_cache_min_cacheable_distance

The minimal distance to the goal in tiles required to be searched in the short path cache. Defaults to `10`.

**Type:** `double`

**Required:** Yes

### short_cache_size

Number of elements in the short cache. Defaults to `5`.

**Type:** `uint`

**Required:** Yes

### short_request_max_steps

The maximum amount of nodes a short request will traverse before being rescheduled as a long request. Defaults to `1000`.

**Type:** `uint`

**Required:** Yes

### short_request_ratio

The amount of steps that are allocated to short requests each tick, as a percentage of all available steps. Defaults to `0.5`, or 50%.

**Type:** `double`

**Required:** Yes

### stale_enemy_with_same_destination_collision_penalty

A penalty that is applied for another unit that is on the way to the goal. This is mainly relevant for situations where a group of units has arrived at the target they are supposed to attack, making units further back circle around to reach the target. Defaults to `30`.

**Type:** `double`

**Required:** Yes

### start_to_goal_cost_multiplier_to_terminate_path_find

If the actual amount of steps is higher than the initial estimate by this factor, pathfinding is terminated. Defaults to `2000.0`.

**Type:** `double`

**Required:** Yes

### use_path_cache

Whether to cache paths at all. Defaults to `true`.

**Type:** `boolean`

**Required:** Yes

