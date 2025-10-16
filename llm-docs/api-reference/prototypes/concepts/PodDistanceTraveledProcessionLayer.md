# PodDistanceTraveledProcessionLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"pod-distance-traveled"`

**Required:** Yes

### reference_group

The group this layer belongs to, for inheritance.

**Type:** `ProcessionLayerInheritanceGroupID`

**Optional:** Yes

### contribute_to_distance_traveled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### distance_traveled_contribution

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### frames

**Type:** Array[`PodDistanceTraveledProcessionBezierControlPoint`]

**Required:** Yes

