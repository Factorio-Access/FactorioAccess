# FeatureFlags

A dictionary of feature flags and their status. It can be used to adjust prototypes based on whether the feature flags are enabled. It is accessible through the global object named `feature_flags`.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### quality

**Type:** `boolean`

**Required:** Yes

### rail_bridges

**Type:** `boolean`

**Required:** Yes

### space_travel

**Type:** `boolean`

**Required:** Yes

### spoiling

**Type:** `boolean`

**Required:** Yes

### freezing

**Type:** `boolean`

**Required:** Yes

### segmented_units

**Type:** `boolean`

**Required:** Yes

### expansion_shaders

**Type:** `boolean`

**Required:** Yes

## Examples

```
```
-- sets coal to spoil only when the spoiling feature flag is enabled
if feature_flags["spoiling"] then
  data.raw.item.coal.spoil_ticks = 600
end
```
```

