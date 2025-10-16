# CreateStickerTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"create-sticker"`

**Required:** Yes

### sticker

Name of a [StickerPrototype](prototype:StickerPrototype) that should be created.

**Type:** `EntityID`

**Required:** Yes

### show_in_tooltip

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### trigger_created_entity

If `true`, [on_trigger_created_entity](runtime:on_trigger_created_entity) will be triggered when the sticker is created.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

