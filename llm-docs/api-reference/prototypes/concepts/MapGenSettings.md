# MapGenSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### default_enable_all_autoplace_controls

Whether undefined `autoplace_controls` should fall back to the default controls or not.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### autoplace_controls

**Type:** Dictionary[`AutoplaceControlID`, `FrequencySizeRichness`]

**Optional:** Yes

### autoplace_settings

Each setting in this table maps the string type to the settings for that type.

**Type:** Dictionary[`"entity"` | `"tile"` | `"decorative"`, `AutoplaceSettings`]

**Optional:** Yes

### property_expression_names

Map of property name (`"elevation"`, etc) to name of noise expression that will provide it. Entries may be omitted. A notable usage is changing autoplace behavior of an entity based on the preset, which cannot be read from a noise expression.

**Type:** Dictionary[`string`, `string` | `boolean` | `double`]

**Optional:** Yes

### starting_points

Array of the positions of the starting areas.

**Type:** Array[`MapPosition`]

**Optional:** Yes

### seed

Read by the game, but not used or set in the GUI.

**Type:** `uint32`

**Optional:** Yes

### width

Width of the map in tiles. Silently limited to 2 000 000, ie. +/- 1 million tiles from the center in both directions.

**Type:** `uint32`

**Optional:** Yes

### height

Height of the map in tiles. Silently limited to 2 000 000, ie. +/- 1 million tiles from the center in both directions.

**Type:** `uint32`

**Optional:** Yes

### starting_area

Size of the starting area. The starting area only effects enemy placement, and has no effect on resources.

**Type:** `MapGenSize`

**Optional:** Yes

### peaceful_mode

If true, enemy creatures will not attack unless the player first attacks them.

**Type:** `boolean`

**Optional:** Yes

### no_enemies_mode

If true, enemy creatures will not naturally spawn from spawners, map gen, or trigger effects.

**Type:** `boolean`

**Optional:** Yes

### cliff_settings

**Type:** `CliffPlacementSettings`

**Optional:** Yes

### territory_settings

**Type:** `TerritorySettings`

**Optional:** Yes

