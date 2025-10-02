# BoxSpecification

A cursor box, for use in [UtilitySprites](prototype:UtilitySprites).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### sprite

**Type:** `Sprite`

**Required:** Yes

### is_whole_box

Whether this is a complete box or just the top left corner. If this is true, `side_length` and `side_height` must be present. Otherwise `max_side_length` must be present.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### side_length

Only loaded, and mandatory if `is_whole_box` is `true`.

**Type:** `double`

**Optional:** Yes

### side_height

Only loaded, and mandatory if `is_whole_box` is `true`.

**Type:** `double`

**Optional:** Yes

### max_side_length

Only loaded, and mandatory if `is_whole_box` is `false`.

**Type:** `double`

**Optional:** Yes

