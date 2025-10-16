# BeaconModuleVisualizations

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### art_style

The visualization is chosen based on the [ModulePrototype::art_style](prototype:ModulePrototype::art_style), meaning if module art style equals beacon module visualization art style then this visualization is chosen. Vanilla uses `"vanilla"` here.

**Type:** `string`

**Required:** Yes

### use_for_empty_slots

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tier_offset

**Type:** `int32`

**Optional:** Yes

**Default:** 0

### slots

The outer array contains the different slots, the inner array contains the different layers for those slots (with different tints etc). Example:

**Type:** Array[Array[`BeaconModuleVisualization`]]

**Optional:** Yes

