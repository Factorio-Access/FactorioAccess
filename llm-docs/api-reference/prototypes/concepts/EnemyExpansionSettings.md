# EnemyExpansionSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### enabled

**Type:** `boolean`

**Required:** Yes

### max_expansion_distance

Distance in chunks from the furthest base around. This prevents expansions from reaching too far into the player's territory.

**Type:** `uint32`

**Required:** Yes

### min_expansion_distance

Distance in chunks from the furthest base around to prevent expansions from being too close to existing bases.

**Type:** `uint32`

**Required:** Yes

### friendly_base_influence_radius

**Type:** `uint32`

**Required:** Yes

### enemy_building_influence_radius

**Type:** `uint32`

**Required:** Yes

### building_coefficient

**Type:** `double`

**Required:** Yes

### other_base_coefficient

**Type:** `double`

**Required:** Yes

### neighbouring_chunk_coefficient

**Type:** `double`

**Required:** Yes

### neighbouring_base_chunk_coefficient

**Type:** `double`

**Required:** Yes

### max_colliding_tiles_coefficient

A chunk has to have at most this much percent unbuildable tiles for it to be considered a candidate. This is to avoid chunks full of water to be marked as candidates.

**Type:** `double`

**Required:** Yes

### settler_group_min_size

Size of the group that goes to build new base.

**Type:** `uint32`

**Required:** Yes

### settler_group_max_size

**Type:** `uint32`

**Required:** Yes

### evolution_group_size_factor

Exponential factor used to determine the size of the settler group based on the evolution factor. The size is calculated as: `size = random(min_size, max_size) * (evolution_group_size_factor ^ evolution_factor)`

**Type:** `double`

**Required:** Yes

### min_expansion_cooldown

Ticks to expand to a single position for a base is used. Cooldown is calculated as follows: `cooldown = lerp(max_expansion_cooldown, min_expansion_cooldown, -e^2 + 2 * e)` where `lerp` is the linear interpolation function, and e is the current evolution factor.

**Type:** `uint32`

**Required:** Yes

### max_expansion_cooldown

In ticks.

**Type:** `uint32`

**Required:** Yes

### build_base_unit_dispatch_cooldown

Cooldown in ticks for dispatching units when building bases.

**Type:** `uint32`

**Required:** Yes

