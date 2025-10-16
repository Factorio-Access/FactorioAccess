# MapGenPresetEnemyExpansionSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### enabled

**Type:** `boolean`

**Optional:** Yes

### max_expansion_distance

Distance in chunks from the furthest base around. This prevents expansions from reaching too far into the player's territory.

**Type:** `uint32`

**Optional:** Yes

### settler_group_min_size

Size of the group that goes to build new base (the game interpolates between min size and max size based on evolution factor).

**Type:** `uint32`

**Optional:** Yes

### settler_group_max_size

**Type:** `uint32`

**Optional:** Yes

### min_expansion_cooldown

Ticks to expand to a single position for a base is used. Cooldown is calculated as follows: `cooldown = lerp(max_expansion_cooldown, min_expansion_cooldown, -e^2 + 2 * e)` where `lerp` is the linear interpolation function, and e is the current evolution factor.

**Type:** `uint32`

**Optional:** Yes

### max_expansion_cooldown

In ticks.

**Type:** `uint32`

**Optional:** Yes

