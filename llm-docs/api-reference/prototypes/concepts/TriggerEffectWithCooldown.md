# TriggerEffectWithCooldown

A [TriggerEffect](prototype:TriggerEffect) with cooldown conditions, used to limit the frequency of trigger effects that would otherwise fire every single tick. If multiple cooldown conditions are defined, then all cooldowns must be satisfied before the effect can be triggered.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### distance_cooldown

The travel distance between triggers that the triggerer must travel between effects. Negative values will mean there is no cooldown.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### initial_distance_cooldown

The initial state of the distance cooldown. In other words, the distance the triggerer must travel before the first effect can be triggered. Useful for staggering multiple effects.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### time_cooldown

The number of ticks that elapse between triggers.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### initial_time_cooldown

The initial amount of time to wait before triggering the effect for the first time.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### effect

**Type:** `TriggerEffect`

**Required:** Yes

