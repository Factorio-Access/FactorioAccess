# TerritorySettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### units

Names of the [SegmentedUnitPrototype](prototype:SegmentedUnitPrototype).

**Type:** Array[`EntityID`]

**Optional:** Yes

### territory_index_expression

Mandatory if `units` is not empty.

**Type:** `string`

**Optional:** Yes

### territory_variation_expression

The result will be converted to integer, clamped and used as an index for `units` array. Negative values will result in empty spawn location.

**Type:** `string`

**Optional:** Yes

**Default:** "0"

### minimum_territory_size

Minimum number of chunks a territory must have. Below this, it will get deleted.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

