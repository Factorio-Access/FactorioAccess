# InfinityInventoryFilter

A single filter used by an infinity-filters instance.

**Type:** Table

## Parameters

### count

The count of the filter. Defaults to 0.

**Type:** `ItemCountType`

**Optional:** Yes

### index

The index of this filter in the filters list. Not required when writing a filter.

**Type:** `uint32`

**Optional:** Yes

### mode

Defaults to `"at-least"`.

**Type:** `"at-least"` | `"at-most"` | `"exactly"`

**Optional:** Yes

### name

Name of the item. When reading a filter, this is a string.

**Type:** `ItemID`

**Required:** Yes

### quality

Quality of the item. Defaults to `"normal"`. When reading a filter, this is a string.

**Type:** `QualityID`

**Optional:** Yes

