# MapGenSize

A floating point number specifying an amount.

For backwards compatibility, MapGenSizes can also be specified as a string, which will be converted to a number (when queried, a number will always be returned).

The map generation algorithm officially supports the range of values the in-game map generation screen shows (specifically `0` and values from `1/6` to `6`). Values outside this range are not guaranteed to work as expected.

**Type:** `float` | `"none"` | `"very-low"` | `"very-small"` | `"very-poor"` | `"low"` | `"small"` | `"poor"` | `"normal"` | `"medium"` | `"regular"` | `"high"` | `"big"` | `"good"` | `"very-high"` | `"very-big"` | `"very-good"`

