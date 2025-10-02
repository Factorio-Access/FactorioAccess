# PuddleTileEffectParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### puddle_noise_texture

**Type:** `EffectTexture`

**Required:** Yes

### water_effect_parameters

**Type:** `WaterTileEffectParameters`

**Optional:** Yes

### water_effect

Only loaded, and mandatory if `water_effect_parameters` is not defined. Must be name of a [TileEffectDefinition](prototype:TileEffectDefinition) which has `shader` set to `"water"`.

**Type:** `TileEffectDefinitionID`

**Optional:** Yes

