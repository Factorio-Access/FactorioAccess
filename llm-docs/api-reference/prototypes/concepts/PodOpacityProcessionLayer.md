# PodOpacityProcessionLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"pod-opacity"`

**Required:** Yes

### lut

**Type:** `ColorLookupTable`

**Required:** Yes

### frames

Default values if unspecified:

- cutscene_opacity : 1.0

- outside_opacity : 1.0

- lut_blend : 0.0

- environment_volume : 1.0

- environment_muffle_intensity : 0.0

**Type:** Array[`PodOpacityProcessionBezierControlPoint`]

**Required:** Yes

