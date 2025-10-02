# MapGenPreset

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### order

Specifies the ordering in the [map generator GUI](https://wiki.factorio.com/Map_generator).

**Type:** `Order`

**Required:** Yes

### default

Whether this is the default preset. If `true`, this preset may not have any other properties besides this and order.

If no MapGenPreset has `default = true`, the preset selector will have a blank preset label, with default settings. The "blank" preset goes away when another preset is selected.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### basic_settings

If any setting is not set, it will use the default values.

**Type:** `MapGenSettings`

**Optional:** Yes

### advanced_settings

If any setting is not set, it will use the default values.

**Type:** `AdvancedMapGenSettings`

**Optional:** Yes

