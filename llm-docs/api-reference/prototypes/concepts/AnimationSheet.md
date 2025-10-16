# AnimationSheet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### variation_count

**Type:** `uint32`

**Required:** Yes

### line_length

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `variation_count`"

### filename

Only loaded, and mandatory if `filenames` is not defined.

The path to the animation file to use.

**Type:** `FileName`

**Optional:** Yes

### filenames

**Type:** Array[`FileName`]

**Optional:** Yes

### lines_per_file

Mandatory if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

