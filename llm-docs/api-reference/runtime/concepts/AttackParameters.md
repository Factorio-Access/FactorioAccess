# AttackParameters

**Type:** Table

## Parameters

### ammo_categories

List of the names of compatible [LuaAmmoCategoryPrototypes](runtime:LuaAmmoCategoryPrototype).

**Type:** Array[`string`]

**Optional:** Yes

### ammo_consumption_modifier

Multiplier applied to the ammo consumption of an attack.

**Type:** `float`

**Required:** Yes

### ammo_type

**Type:** `AmmoType`

**Optional:** Yes

### cooldown

Minimum amount of ticks between shots. If this is less than `1`, multiple shots can be performed per tick.

**Type:** `float`

**Required:** Yes

### damage_modifier

Multiplier applied to the damage of an attack.

**Type:** `float`

**Required:** Yes

### fire_penalty

When searching for the nearest enemy to attack, `fire_penalty` is added to the enemy's distance if they are on fire.

**Type:** `float`

**Required:** Yes

### health_penalty

When searching for an enemy to attack, a higher `health_penalty` will discourage targeting enemies with high health. A negative penalty will do the opposite.

**Type:** `float`

**Required:** Yes

### min_attack_distance

If less than `range`, the entity will choose a random distance between `range` and `min_attack_distance` and attack from that distance. Used for spitters.

**Type:** `float`

**Required:** Yes

### min_range

Minimum range of attack. Used with flamethrower turrets to prevent self-immolation.

**Type:** `float`

**Required:** Yes

### movement_slow_down_cooldown

**Type:** `float`

**Required:** Yes

### movement_slow_down_factor

**Type:** `double`

**Required:** Yes

### range

Maximum range of attack.

**Type:** `float`

**Required:** Yes

### range_mode

Defines how the range is determined.

**Type:** `RangeMode`

**Required:** Yes

### rotate_penalty

When searching for an enemy to attack, a higher `rotate_penalty` will discourage targeting enemies that would take longer to turn to face.

**Type:** `float`

**Required:** Yes

### turn_range

The arc that the entity can attack in as a fraction of a circle. A value of `1` means the full 360 degrees.

**Type:** `float`

**Required:** Yes

### type

The type of AttackParameter.

**Type:** `"projectile"` | `"stream"` | `"beam"`

**Required:** Yes

### warmup

Number of ticks it takes for the weapon to actually shoot after it has been ordered to do so.

**Type:** `uint`

**Required:** Yes

