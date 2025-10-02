# TileTransitionsVariants

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### main

**Type:** Array[`TileMainPictures`]

**Optional:** Yes

### material_texture_width_in_tiles

**Type:** `uint8`

**Optional:** Yes

**Default:** 8

### material_texture_height_in_tiles

**Type:** `uint8`

**Optional:** Yes

**Default:** 8

### material_background

**Type:** `MaterialTextureParameters`

**Optional:** Yes

### light

**Type:** Array[`TileLightPictures`]

**Optional:** Yes

### material_light

Must have the same `count` as material_background.

**Type:** `MaterialTextureParameters`

**Optional:** Yes

### empty_transitions

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### transition

Only loaded, and mandatory if `empty_transitions` is `false`.

**Type:** `TileTransitions`

**Optional:** Yes

