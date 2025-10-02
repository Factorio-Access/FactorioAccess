# RailSignalStaticSpriteLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### sprites

**Type:** `Animation`

**Required:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "rail-chain-signal-metal"

### hide_if_simulation

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### hide_if_not_connected_to_rails

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### shifts

Must be an empty array or contain exactly 16 values.

**Type:** Array[`MapPosition`]

**Optional:** Yes

### align_to_frame_index

**Type:** Array[`uint8`]

**Optional:** Yes

