# DestroyDecorativesTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"destroy-decoratives"`

**Required:** Yes

### radius

**Type:** `float`

**Required:** Yes

### from_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "first layer"

### to_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "last layer"

### include_soft_decoratives

Soft decoratives are those where [DecorativePrototype::grows_through_rail_path](prototype:DecorativePrototype::grows_through_rail_path) is `true`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### include_decals

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### invoke_decorative_trigger

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### decoratives_with_trigger_only

If `true`, only decoratives with a [DecorativePrototype::trigger_effect](prototype:DecorativePrototype::trigger_effect) will be destroyed.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

