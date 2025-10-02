# UpgradeMapperSource

**Type:** Table

## Parameters

### comparator

The quality comparison type.

**Type:** `ComparatorString`

**Optional:** Yes

### module_filter

When upgrading modules, this defines the specific entities to apply the upgrade to. `nil` applies it to all entities.

**Type:** `EntityIDFilter`

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

