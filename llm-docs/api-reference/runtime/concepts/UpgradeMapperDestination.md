# UpgradeMapperDestination

**Type:** Table

## Parameters

### module_limit

When upgrading modules, this defines the maximum number of this module to be installed in the destination entity. `0` or `nil` means no limit.

**Type:** `uint16`

**Optional:** Yes

### module_slots

When upgrading entities, this defines explicit modules to be installed in the destination entity. Lists empty slots as `{}`.

**Type:** Array[`BlueprintItemIDAndQualityIDPair`]

**Optional:** Yes

### name

Name of the item or entity.

**Type:** `string`

**Optional:** Yes

### quality

Name of the quality prototype.

**Type:** `string`

**Optional:** Yes

### type

**Type:** `"item"` | `"entity"`

**Required:** Yes

