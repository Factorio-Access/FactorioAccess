# MapGenPresetPollutionSettings

The pollution settings, the values are for 60 ticks (1 second).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### enabled

**Type:** `boolean`

**Optional:** Yes

### diffusion_ratio

Must be <= 0.25. Amount that is diffused to neighboring chunks.

**Type:** `double`

**Optional:** Yes

### ageing

Must be >= 0.1. Also known as absorption modifier.

**Type:** `double`

**Optional:** Yes

### min_pollution_to_damage_trees

**Type:** `double`

**Optional:** Yes

### enemy_attack_pollution_consumption_modifier

Must be >= 0.1.

**Type:** `double`

**Optional:** Yes

### pollution_restored_per_tree_damage

**Type:** `double`

**Optional:** Yes

