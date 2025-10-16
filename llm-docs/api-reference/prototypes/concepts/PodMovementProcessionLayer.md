# PodMovementProcessionLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"pod-movement"`

**Required:** Yes

### reference_group

The group this layer belongs to, for inheritance.

**Type:** `ProcessionLayerInheritanceGroupID`

**Optional:** Yes

### inherit_from

Adds the final position value from given layer to this one.

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

**Type:** Array[`PodMovementProcessionBezierControlPoint`]

**Required:** Yes

## Examples

```
```
{
  type = "pod-movement",
  frames =
  {
    { timestamp = 700 , tilt = 0.0               , tilt_t = 0 },
    { timestamp = 700 , offset = {0, 0 - 500}    , offset_t = {0, -40} },
    { timestamp = 900 , offset = {15, -60 - 500} , offset_t = {-10, -10} },
    { timestamp = 900 , opacity = 1.0 },
    { timestamp = 960 , tilt = 0.05              , tilt_t = -0.03 },
    { timestamp = 1050, tilt = 0.25              , tilt_t = 0 },
    { timestamp = 1050, offset = {40, -70 - 500} , offset_t = {-1, 0} },
    { timestamp = 1050, opacity = 0.0 },
    { timestamp = 700 , offset_rate = 0 },
    { timestamp = 1050, offset_rate = 1.0 }
  }
}
```
```

