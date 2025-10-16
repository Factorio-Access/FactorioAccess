# LightningProperties

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### lightnings_per_chunk_per_tick

**Type:** `double`

**Required:** Yes

### search_radius

**Type:** `double`

**Required:** Yes

### lightning_types

Cannot be an empty array. Names of [lightning entities](prototype:LightningPrototype).

**Type:** Array[`EntityID`]

**Required:** Yes

### priority_rules

**Type:** Array[`LightningPriorityRule`]

**Optional:** Yes

### exemption_rules

**Type:** Array[`LightningRuleBase`]

**Optional:** Yes

### lightning_multiplier_at_day

Must be in range `[0, 1]`.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### lightning_multiplier_at_night

Must be in range `[0, 1]`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### multiplier_surface_property

When set, value of that surface property will be used as an additional multiplier to the lightning frequency.

Value of that surface property is divided by [default_value](prototype:SurfacePropertyPrototype::default_value) which means a default value must be positive (cannot be 0). When surface property has value at default, then this additional multiplier has value of 1.

**Type:** `SurfacePropertyID`

**Optional:** Yes

### lightning_warning_icon

Icon to render on top of entities that are endangered by lightning. When not provided, a [UtilitySprites::lightning_warning_icon](prototype:UtilitySprites::lightning_warning_icon) will be used instead.

**Type:** `Sprite`

**Optional:** Yes

