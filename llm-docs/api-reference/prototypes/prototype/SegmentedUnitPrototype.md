# SegmentedUnitPrototype

Entity composed of multiple segment entities that trail behind the head.

**Parent:** [SegmentPrototype](SegmentPrototype.md)
**Type name:** `segmented-unit`
**Visibility:** space_age

## Properties

### vision_distance

Vision distance, affects scanning radius for enemies to attack. Must be non-negative. Max 100.

**Type:** `double`

**Required:** Yes

### attack_parameters

Attack parameters for when a segmented unit is attacking something.

**Type:** `AttackParameters`

**Optional:** Yes

### revenge_attack_parameters

Attack parameters for when a segmented unit is attacking something in retaliation because the target first attacked it.

**Type:** `AttackParameters`

**Optional:** Yes

### territory_radius

The territory radius in chunks. The chunk in which the entity spawned is included.

**Type:** `uint32`

**Required:** Yes

### enraged_duration

The number of ticks to remain enraged after last taking damage.

**Type:** `MapTick`

**Required:** Yes

### patrolling_speed

The movement speed while patrolling, in tiles per tick. Cannot be negative.

**Type:** `double`

**Required:** Yes

### investigating_speed

The movement speed while investigating, in tiles per tick. Cannot be negative.

**Type:** `double`

**Required:** Yes

### attacking_speed

The movement speed while attacking, in tiles per tick. Cannot be negative.

**Type:** `double`

**Required:** Yes

### enraged_speed

The movement speed while enraged, in tiles per tick. Cannot be negative.

**Type:** `double`

**Required:** Yes

### acceleration_rate

The acceleration rate when moving from one state to another. Cannot be negative.

**Type:** `double`

**Required:** Yes

### turn_radius

Turn radius, in tiles. Cannot be negative.

**Type:** `double`

**Required:** Yes

### patrolling_turn_radius

Cannot be negative.

**Type:** `double`

**Optional:** Yes

**Default:** "Value of `turn_radius`"

### turn_smoothing

Attempts to smooth out tight turns by limiting how quickly the unit can change turning directions. 0 means no turn smoothing, 1 means no turning whatsoever. Must be between 0 and 1.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### ticks_per_scan

The number of ticks between territory scans. Greater values means longer time between scans, which means a slower reaction time. Cannot be `0`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 120

### segment_engine

Specification of the segment engine, which should contain a list of the segments that compose the entity's body.

**Type:** `SegmentEngineSpecification`

**Required:** Yes

### roar

**Type:** `Sound`

**Optional:** Yes

### roar_probability

The default is 1.0f / (6.0f * 60.0f), average pause between roars is 6 seconds.

**Type:** `float`

**Optional:** Yes

**Default:** 0.00277777785

### hurt_roar

Sound which plays when health ratio drops below any of `hurt_thresholds`.

**Type:** `Sound`

**Optional:** Yes

### hurt_thresholds

Only loaded, and mandatory if `hurt_roar` is defined.

**Type:** Array[`float`]

**Optional:** Yes

