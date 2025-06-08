# TileEffectDefinition

Used to define the parameters for tile shaders.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Name of the tile-effect.

#### shader

**Type:** 



#### type

**Type:** `tile-effect`



### Optional Properties

#### puddle

**Type:** `PuddleTileEffectParameters`

Only loaded, and mandatory if `shader` is `"puddle"`.

#### space

**Type:** `SpaceTileEffectParameters`

Only loaded, and mandatory if `shader` is `"space"`.

#### water

**Type:** `WaterTileEffectParameters`

Only loaded, and mandatory if `shader` is `"water"`.

