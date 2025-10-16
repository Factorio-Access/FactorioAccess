# StreamAttackParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"stream"`

**Required:** Yes

### fluid_consumption

**Type:** `FluidAmount`

**Optional:** Yes

**Default:** 0.0

### gun_barrel_length

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### projectile_creation_parameters

**Type:** `CircularProjectileCreationSpecification`

**Optional:** Yes

### gun_center_shift

**Type:** `Vector` | `GunShift4Way`

**Optional:** Yes

### fluids

Controls which fluids can fuel this stream attack and their potential damage bonuses.

**Type:** Array[`StreamFluidProperties`]

**Optional:** Yes

