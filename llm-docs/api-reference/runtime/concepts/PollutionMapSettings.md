# PollutionMapSettings

These values are for the time frame of one second (60 ticks).

**Type:** Table

## Parameters

### ageing

The amount of pollution eaten by a chunk's tiles as a percentage of 1. Also known as absorption modifier. Defaults to `1`.

**Type:** `double`

**Required:** Yes

### diffusion_ratio

The amount that is diffused to a neighboring chunk (possibly repeated for other directions as well). Defaults to `0.02`.

**Type:** `double`

**Required:** Yes

### enabled

Whether pollution is enabled at all.

**Type:** `boolean`

**Required:** Yes

### enemy_attack_pollution_consumption_modifier

Defaults to `1`.

**Type:** `double`

**Required:** Yes

### expected_max_per_chunk

Any amount of pollution larger than this value is visualized as this value instead. Defaults to `150`.

**Type:** `double`

**Required:** Yes

### max_pollution_to_restore_trees

Defaults to `20`.

**Type:** `double`

**Required:** Yes

### min_pollution_to_damage_trees

Defaults to `60`.

**Type:** `double`

**Required:** Yes

### min_to_diffuse

The amount of PUs that need to be in a chunk for it to start diffusing. Defaults to `15`.

**Type:** `double`

**Required:** Yes

### min_to_show_per_chunk

Any amount of pollution smaller than this value (but bigger than zero) is visualized as this value instead. Defaults to `50`.

**Type:** `double`

**Required:** Yes

### pollution_per_tree_damage

Defaults to `50`.

**Type:** `double`

**Required:** Yes

### pollution_restored_per_tree_damage

Defaults to `10`.

**Type:** `double`

**Required:** Yes

### pollution_with_max_forest_damage

Defaults to `150`.

**Type:** `double`

**Required:** Yes

