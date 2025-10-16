# PlanetPrototype

**Parent:** [SpaceLocationPrototype](SpaceLocationPrototype.md)
**Type name:** `planet`

## Properties

### map_seed_offset

**Type:** `uint32`

**Optional:** Yes

**Default:** "CRC checksum of `name`"

### entities_require_heating

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### pollutant_type

**Type:** `AirbornePollutantID`

**Optional:** Yes

### persistent_ambient_sounds

**Type:** `PersistentWorldAmbientSoundsDefinition`

**Optional:** Yes

### surface_render_parameters

**Type:** `SurfaceRenderParameters`

**Optional:** Yes

### player_effects

**Type:** `Trigger`

**Optional:** Yes

### ticks_between_player_effects

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### map_gen_settings

**Type:** `PlanetPrototypeMapGenSettings`

**Optional:** Yes

### surface_properties

**Type:** Dictionary[`SurfacePropertyID`, `double`]

**Optional:** Yes

### lightning_properties

**Type:** `LightningProperties`

**Optional:** Yes

