# PollutionSettings

The pollution settings, the values are for 60 ticks (1 second).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### enabled

**Type:** `boolean`

**Required:** Yes

### diffusion_ratio

Amount that is diffused to neighboring chunks.

**Type:** `double`

**Required:** Yes

### min_to_diffuse

This much pollution units must be on the chunk to start diffusing.

**Type:** `double`

**Required:** Yes

### ageing

Constant modifier a percentage of 1; the pollution eaten by a chunks tiles. Also known as absorption modifier.

**Type:** `double`

**Required:** Yes

### expected_max_per_chunk

Anything bigger than this is visualized as this value.

**Type:** `double`

**Required:** Yes

### min_to_show_per_chunk

Anything lower than this (but > 0) is visualized as this value.

**Type:** `double`

**Required:** Yes

### min_pollution_to_damage_trees

**Type:** `double`

**Required:** Yes

### pollution_with_max_forest_damage

**Type:** `double`

**Required:** Yes

### pollution_restored_per_tree_damage

**Type:** `double`

**Required:** Yes

### pollution_per_tree_damage

**Type:** `double`

**Required:** Yes

### max_pollution_to_restore_trees

**Type:** `double`

**Required:** Yes

### enemy_attack_pollution_consumption_modifier

**Type:** `double`

**Required:** Yes

