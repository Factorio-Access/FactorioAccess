# IconSequencePositioning

Specification of where and how should be the icons of individual inventories be drawn.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### inventory_index

**Type:** `defines.inventory`

**Required:** Yes

### max_icons_per_row

**Type:** `uint8`

**Optional:** Yes

**Default:** "width of entity selection box / 0.75"

### max_icon_rows

**Type:** `uint8`

**Optional:** Yes

**Default:** "width of entity selection box / 1.5"

### shift

**Type:** `Vector`

**Optional:** Yes

**Default:** "{0, 0.7}"

### scale

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### separation_multiplier

**Type:** `float`

**Optional:** Yes

**Default:** 1.1

### multi_row_initial_height_modifier

**Type:** `float`

**Optional:** Yes

**Default:** -0.1

