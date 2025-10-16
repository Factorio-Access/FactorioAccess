# SpriteSheet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

If this property is present, all SpriteSheet definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

If this property is present, all other properties, including those inherited from SpriteParameters, are ignored.

**Type:** Array[`SpriteSheet`]

**Optional:** Yes

### variation_count

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### repeat_count

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### line_length

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `variation_count`"

### filenames

**Type:** Array[`FileName`]

**Optional:** Yes

### lines_per_file

Mandatory if `filenames` is defined.

**Type:** `uint32`

**Optional:** Yes

### dice

Number of slices this is sliced into when using the "optimized atlas packing" option. If you are a modder, you can just ignore this property. Example: If this is 4, the sprite will be sliced into a 4x4 grid.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_x

Same as `dice` above, but this specifies only how many slices there are on the x axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_y

Same as `dice` above, but this specifies only how many slices there are on the y axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

### filename

Only loaded, and mandatory if `layers` and `filenames` are not defined.

The path to the sprite file to use.

**Type:** `FileName`

**Optional:** Yes

