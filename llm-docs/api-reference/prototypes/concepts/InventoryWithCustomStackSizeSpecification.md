# InventoryWithCustomStackSizeSpecification

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### stack_size_multiplier

Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### stack_size_min

Must be >= 1.

**Type:** `ItemCountType`

**Optional:** Yes

**Default:** 1

### stack_size_max

Must be >= stack_size_min.

**Type:** `ItemCountType`

**Optional:** Yes

### stack_size_override

Each record value must be >= 1. For non-stackable items this value will be ignored.

**Type:** Dictionary[`ItemID`, `ItemCountType`]

**Optional:** Yes

### with_bar

**Type:** `boolean`

**Optional:** Yes

**Default:** False

