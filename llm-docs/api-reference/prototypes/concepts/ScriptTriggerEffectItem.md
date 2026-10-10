# ScriptTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"script"`

**Required:** Yes

### effect_id

The effect ID that will be provided in [on_script_trigger_effect](runtime:on_script_trigger_effect).

**Type:** `string`

**Required:** Yes

### custom_event

Event to be raised. When set, that event will be raised instead of [on_script_trigger_effect](runtime:on_script_trigger_effect).

**Type:** `CustomEventID`

**Optional:** Yes

