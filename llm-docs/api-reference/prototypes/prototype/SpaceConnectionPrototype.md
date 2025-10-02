# SpaceConnectionPrototype

**Parent:** [Prototype](Prototype.md)
**Type name:** `space-connection`

## Properties

### from

**Type:** `SpaceLocationID`

**Required:** Yes

### to

**Type:** `SpaceLocationID`

**Required:** Yes

### length

Length of the space connection in km.

Cannot be 0.

**Type:** `uint32`

**Optional:** Yes

**Default:** 600

### asteroid_spawn_definitions

**Type:** Array[`SpaceConnectionAsteroidSpawnDefinition`]

**Optional:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

