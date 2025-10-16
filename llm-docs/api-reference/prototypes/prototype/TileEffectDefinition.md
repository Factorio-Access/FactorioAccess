# TileEffectDefinition

Used to define the parameters for tile shaders.

**Type name:** `tile-effect`
**Instance limit:** 32

## Properties

### type

**Type:** `"tile-effect"`

**Required:** Yes

### name

Name of the tile-effect.

**Type:** `string`

**Required:** Yes

### shader

**Type:** `"water"` | `"space"` | `"puddle"`

**Required:** Yes

### water

Only loaded, and mandatory if `shader` is `"water"`.

**Type:** `WaterTileEffectParameters`

**Optional:** Yes

### space

Only loaded, and mandatory if `shader` is `"space"`.

**Type:** `SpaceTileEffectParameters`

**Optional:** Yes

### puddle

Only loaded, and mandatory if `shader` is `"puddle"`.

**Type:** `PuddleTileEffectParameters`

**Optional:** Yes

