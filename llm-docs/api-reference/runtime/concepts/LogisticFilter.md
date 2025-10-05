# LogisticFilter

**Type:** Table

## Parameters

### import_from

The space location to import from.

**Type:** `SpaceLocationID`

**Optional:** Yes

### max

The maximum amount to keep in inventory. `nil` for infinite.

**Type:** `ItemCountType`

**Optional:** Yes

### min

The minimum amount to satisfy. If `min` is non-zero, and `value` is present, then the quality condition inside `value` does not allow quality ranges.

**Type:** `int32`

**Optional:** Yes

### minimum_delivery_count

The minimum count that will be delivered to a space platform. `nil` if unchanged from the default.

**Type:** `ItemCountType`

**Optional:** Yes

### value

The item filter to put into the slot.

**Type:** `SignalFilter`

**Optional:** Yes

