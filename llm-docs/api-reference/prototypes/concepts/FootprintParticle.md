# FootprintParticle

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### tiles

The tiles this footprint particle is shown on when the player walks over them.

**Type:** Array[`TileID`]

**Required:** Yes

### particle_name

The name of the particle that should be created when the character walks on the defined tiles.

**Type:** `ParticleID`

**Optional:** Yes

### use_as_default

Whether this footprint particle should be the default particle that is used for `tiles` that don't have an associated footprint particle.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

