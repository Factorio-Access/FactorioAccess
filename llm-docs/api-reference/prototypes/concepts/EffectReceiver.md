# EffectReceiver

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### base_effect

**Type:** `Effect`

**Optional:** Yes

### uses_module_effects

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### uses_beacon_effects

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### uses_surface_effects

Controls whether [LuaSurface::global_effect](runtime:LuaSurface::global_effect) affects this receiver.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### uses_local_effects

Controls whether [LuaEntity::local_effect](runtime:LuaEntity::local_effect) affects this receiver.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### consumption_limits

Limits total consumption effect value.

Low limit cannot be less than `-0.9999`. High limit cannot be greater than `1000`.

**Type:** `EffectValueRange`

**Optional:** Yes

**Default:** "`{ low = -0.8, high = 1000 }`"

### speed_limits

Limits total speed effect value.

Low limit cannot be less than `-0.9999`. High limit cannot be greater than `1000`.

**Type:** `EffectValueRange`

**Optional:** Yes

**Default:** "`{ low = -0.8, high = 1000 }`"

### productivity_limits

Limits total productivity effect value. This limit is applied before any productivity gained from research is added. Afterwards, productivity is clamped again to be non-negative. For crafting machines, it is also clamped to [RecipePrototype::maximum_productivity](prototype:RecipePrototype::maximum_productivity).

Low limit cannot be less than `-0.9999`. High limit cannot be greater than `1000`.

**Type:** `EffectValueRange`

**Optional:** Yes

**Default:** "`{ low = -0.8, high = 1000 }`"

### pollution_limits

Limits total pollution effect value.

Low limit cannot be less than `-0.9999`. High limit cannot be greater than `1000`.

**Type:** `EffectValueRange`

**Optional:** Yes

**Default:** "`{ low = -0.8, high = 1000 }`"

### quality_limits

Limits total quality effect value.

Low limit cannot be less than `-1000`. High limit cannot be greater than `1000`.

**Type:** `EffectValueRange`

**Optional:** Yes

**Default:** "`{ low = 0, high = 1000 }`"

