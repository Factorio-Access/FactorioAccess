# EffectReceiver

**Type:** Table

## Parameters

### base_effect

**Type:** `Effect`

**Required:** Yes

### consumption_limits

**Type:** `EffectValueRange`

**Required:** Yes

### pollution_limits

**Type:** `EffectValueRange`

**Required:** Yes

### productivity_limits

**Type:** `EffectValueRange`

**Required:** Yes

### quality_limits

**Type:** `EffectValueRange`

**Required:** Yes

### speed_limits

**Type:** `EffectValueRange`

**Required:** Yes

### uses_beacon_effects

**Type:** `boolean`

**Required:** Yes

### uses_local_effects

Controls whether [LuaEntity::local_effect](runtime:LuaEntity::local_effect) affects this receiver.

**Type:** `boolean`

**Required:** Yes

### uses_module_effects

**Type:** `boolean`

**Required:** Yes

### uses_surface_effects

Controls whether [LuaSurface::global_effect](runtime:LuaSurface::global_effect) affects this receiver.

**Type:** `boolean`

**Required:** Yes

