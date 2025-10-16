# CustomTooltipField

Allows to add extra description items to the tooltip.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### name

**Type:** `LocalisedString`

**Required:** Yes

### value

**Type:** `LocalisedString`

**Required:** Yes

### quality_header

**Type:** `string`

**Optional:** Yes

**Default:** "quality-tooltip.increases"

### quality_values

Custom values per quality level. If a value is not provided for a specific quality, [CustomTooltipField::value](prototype:CustomTooltipField::value) will be used instead.

**Type:** Dictionary[`QualityID`, `LocalisedString`]

**Optional:** Yes

### order

Ordering within all description items (modded and un-modded). Items with smaller order values are shown above items with larger values.

**Type:** `uint8`

**Optional:** Yes

**Default:** 100

### show_in_factoriopedia

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### show_in_tooltip

**Type:** `boolean`

**Optional:** Yes

**Default:** True

