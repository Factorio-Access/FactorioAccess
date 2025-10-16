# FootstepTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### tiles

**Type:** Array[`TileID`]

**Required:** Yes

### actions

Can be used to specify multiple CreateParticleTriggerEffectItems. If this property is defined, all properties inherited from CreateParticleTriggerEffectItem are ignored.

**Type:** Array[`CreateParticleTriggerEffectItem`]

**Optional:** Yes

### use_as_default

When `true`, the trigger(s) defined in `actions` are the default triggers for tiles that don't have an associated footstep particle trigger. (ie. don't show up in one of the "tiles" lists).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

