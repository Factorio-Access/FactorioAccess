# WaitCondition

**Type:** Table

## Parameters

### compare_type

Specifies how this condition is to be compared with the preceding conditions in the corresponding `wait_conditions` array. Always present when reading, defaults to `"and"` when writing.

**Type:** `"and"` | `"or"`

**Optional:** Yes

### condition

This is a CircuitCondition and only present when `type` is `"item_count"`, `"circuit"`, `"fluid_count"`, `"fuel_item_count_all"`, or `"fuel_item_count_any"`, and a circuit condition is configured. This is a BlueprintItemIDAndQualityIDPair and only present when `type` is `"request_satisfied"` or `"request_not_satisfied"`

**Type:** `CircuitCondition` | `BlueprintItemIDAndQualityIDPair`

**Optional:** Yes

### damage

Amount of damage to take when `type` is `"damage_taken"`.

**Type:** `uint32`

**Optional:** Yes

### planet

Name of the space location. Only present when `type` is "`any_planet_import_zero`" and a planet is configured.

**Type:** `string`

**Optional:** Yes

### station

Name of the station. Only present when `type` is "`specific_destination_full`", "`specific_destination_not_full`", "`at_station`", or "`not_at_station`", and a station is configured.

**Type:** `string`

**Optional:** Yes

### ticks

Number of ticks to wait when `type` is `"time"`, or number of ticks of inactivity when `type` is `"inactivity"`.

**Type:** `uint32`

**Optional:** Yes

### type

**Type:** `WaitConditionType`

**Required:** Yes

