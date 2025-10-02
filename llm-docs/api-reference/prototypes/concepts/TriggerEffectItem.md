# TriggerEffectItem

The abstract base of all [TriggerEffects](prototype:TriggerEffect).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### repeat_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 1

### repeat_count_deviation

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### probability

Must be greater than `0` and less than or equal to `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### affects_target

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### show_in_tooltip

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### damage_type_filters

Guaranteed to work with [EntityWithHealthPrototype::damaged_trigger_effect](prototype:EntityWithHealthPrototype::damaged_trigger_effect) and [EntityWithHealthPrototype::dying_trigger_effect](prototype:EntityWithHealthPrototype::dying_trigger_effect). Unknown if it works with other properties that use [TriggerEffect](prototype:TriggerEffect).

**Type:** `DamageTypeFilters`

**Optional:** Yes

