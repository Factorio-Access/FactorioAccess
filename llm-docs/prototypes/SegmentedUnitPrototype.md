# SegmentedUnitPrototype

Entity composed of multiple segment entities that trail behind the head.

**Parent:** `SegmentPrototype`

## Properties

### Mandatory Properties

#### acceleration_rate

**Type:** `double`

The acceleration rate when moving from one state to another. Cannot be negative.

#### attacking_speed

**Type:** `double`

The movement speed while attacking, in tiles per tick. Cannot be negative.

#### enraged_duration

**Type:** `uint32`

The number of ticks to remain enraged after last taking damage.

#### enraged_speed

**Type:** `double`

The movement speed while enraged, in tiles per tick. Cannot be negative.

#### investigating_speed

**Type:** `double`

The movement speed while investigating, in tiles per tick. Cannot be negative.

#### patrolling_speed

**Type:** `double`

The movement speed while patrolling, in tiles per tick. Cannot be negative.

#### segment_engine

**Type:** `SegmentEngineSpecification`

Specification of the segment engine, which should contain a list of the segments that compose the entity's body.

#### territory_radius

**Type:** `uint32`

The territory radius in chunks. The chunk in which the entity spawned is included.

#### turn_radius

**Type:** `double`

Turn radius, in tiles. Cannot be negative.

#### vision_distance

**Type:** `double`

Vision distance, affects scanning radius for enemies to attack. Must be non-negative. Max 100.

### Optional Properties

#### attack_parameters

**Type:** `AttackParameters`

Attack parameters for when a segmented unit is attacking something.

#### hurt_roar

**Type:** `Sound`

Sound which plays when health ratio drops below any of `hurt_thresholds`.

#### hurt_thresholds

**Type:** ``float`[]`

Only loaded, and mandatory if `hurt_roar` is defined.

#### patrolling_turn_radius

**Type:** `double`

Cannot be negative.

**Default:** `Value of `turn_radius``

#### revenge_attack_parameters

**Type:** `AttackParameters`

Attack parameters for when a segmented unit is attacking something in retaliation because the target first attacked it.

#### roar

**Type:** `Sound`



#### roar_probability

**Type:** `float`

The default is 1.0f / (6.0f * 60.0f), average pause between roars is 6 seconds.

**Default:** `{'complex_type': 'literal', 'value': 0.00277777785}`

#### ticks_per_scan

**Type:** `uint32`

The number of ticks between territory scans. Greater values means longer time between scans, which means a slower reaction time. Cannot be `0`.

**Default:** `{'complex_type': 'literal', 'value': 120}`

#### turn_smoothing

**Type:** `double`

Attempts to smooth out tight turns by limiting how quickly the unit can change turning directions. 0 means no turn smoothing, 1 means no turning whatsoever. Must be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 1}`

