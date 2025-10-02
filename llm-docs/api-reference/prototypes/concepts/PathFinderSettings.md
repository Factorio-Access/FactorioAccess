# PathFinderSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### fwd2bwd_ratio

The pathfinder performs a step of the backward search every `fwd2bwd_ratio`'th step. The minimum allowed value is 2, which means symmetric search.

**Type:** `uint32`

**Required:** Yes

### goal_pressure_ratio

When comparing nodes in open which one to check next, heuristic value is multiplied by this ratio. The higher the number the more is the search directed directly towards the goal.

**Type:** `double`

**Required:** Yes

### use_path_cache

**Type:** `boolean`

**Required:** Yes

### max_steps_worked_per_tick

When this is exhausted no more requests are allowed, at the moment the first path to exhaust this will be finished (even if it is hundreds of steps).

**Type:** `double`

**Required:** Yes

### max_work_done_per_tick

**Type:** `uint32`

**Required:** Yes

### short_cache_size

Number of elements in the cache.

**Type:** `uint32`

**Required:** Yes

### long_cache_size

**Type:** `uint32`

**Required:** Yes

### short_cache_min_cacheable_distance

Minimal distance to goal for path to be searched in short path cache.

**Type:** `double`

**Required:** Yes

### short_cache_min_algo_steps_to_cache

Minimal number of algorithm steps for path to be inserted into the short path cache.

**Type:** `uint32`

**Required:** Yes

### long_cache_min_cacheable_distance

Minimal distance to goal for path to be searched in long path cache.

**Type:** `double`

**Required:** Yes

### cache_max_connect_to_cache_steps_multiplier

When searching for connection to path cache path, search at most for this number of steps times the initial estimate.

**Type:** `uint32`

**Required:** Yes

### cache_accept_path_start_distance_ratio

When looking for path from cache make sure it doesn't start too far from requested start in relative distance terms.

**Type:** `double`

**Required:** Yes

### cache_accept_path_end_distance_ratio

When looking for path from cache make sure it doesn't end too far from requested end. This is typically higher than accept value for the start because the end target can be moving.

**Type:** `double`

**Required:** Yes

### negative_cache_accept_path_start_distance_ratio

Same as cache_accept_path_start_distance_ratio, but used for negative cache queries.

**Type:** `double`

**Required:** Yes

### negative_cache_accept_path_end_distance_ratio

Same as cache_accept_path_end_distance_ratio, but used for negative cache queries.

**Type:** `double`

**Required:** Yes

### cache_path_start_distance_rating_multiplier

When assigning rating to the best path this * start distances is considered.

**Type:** `double`

**Required:** Yes

### cache_path_end_distance_rating_multiplier

When assigning rating to the best path this * end distances is considered. This is typically higher than value for the start to achieve better path end quality.

**Type:** `double`

**Required:** Yes

### stale_enemy_with_same_destination_collision_penalty

Somewhere along the path is stuck enemy we need to avoid. This is mainly to handle situations when units have arrived and are attacking the target then units further in the back will use this and run around the target.

**Type:** `double`

**Required:** Yes

### ignore_moving_enemy_collision_distance

If there is a moving unit further than this we don't really care.

**Type:** `double`

**Required:** Yes

### enemy_with_different_destination_collision_penalty

Enemy is not moving/or is too close and has different destination.

**Type:** `double`

**Required:** Yes

### general_entity_collision_penalty

Simplification for now; collision with everything else is this.

**Type:** `double`

**Required:** Yes

### general_entity_subsequent_collision_penalty

Collision penalty for successors of positions that require destroy to reach.

**Type:** `double`

**Required:** Yes

### extended_collision_penalty

Collision penalty for collisions in the extended bounding box but outside the entity's actual bounding box.

**Type:** `double`

**Required:** Yes

### max_clients_to_accept_any_new_request

Up until this amount any client will be served by the path finder (no estimate on the path length).

**Type:** `uint32`

**Required:** Yes

### max_clients_to_accept_short_new_request

From max_clients_to_accept_any_new_request till this one only those that have a short estimate will be served.

**Type:** `uint32`

**Required:** Yes

### direct_distance_to_consider_short_request

This is the "threshold" to decide what is short and what is not.

**Type:** `uint32`

**Required:** Yes

### short_request_max_steps

If a short request takes more than this many steps, it will be rescheduled as a long request.

**Type:** `uint32`

**Required:** Yes

### short_request_ratio

How many steps will be allocated to short requests each tick, as a ratio of all available steps per tick.

**Type:** `double`

**Required:** Yes

### min_steps_to_check_path_find_termination

Absolute minimum of steps that will be performed for every path find request no matter what.

**Type:** `uint32`

**Required:** Yes

### start_to_goal_cost_multiplier_to_terminate_path_find

If the current actual cost from start is higher than this times estimate of start to goal then path finding is terminated.

**Type:** `double`

**Required:** Yes

### overload_levels

**Type:** Array[`uint32`]

**Required:** Yes

### overload_multipliers

**Type:** Array[`double`]

**Required:** Yes

### negative_path_cache_delay_interval

**Type:** `uint32`

**Required:** Yes

