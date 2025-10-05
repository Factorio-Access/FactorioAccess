# MiningDrillGraphicsSet

Used by [MiningDrillPrototype](prototype:MiningDrillPrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### frozen_patch

**Type:** `Sprite4Way`

**Optional:** Yes

### reset_animation_when_frozen

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### circuit_connector_layer

Render layer(s) for all directions of the circuit connectors.

**Type:** `RenderLayer` | `CircuitConnectorLayer`

**Optional:** Yes

**Default:** "object"

### circuit_connector_secondary_draw_order

Secondary draw order(s) for all directions of the circuit connectors.

**Type:** `int8` | `CircuitConnectorSecondaryDrawOrder`

**Optional:** Yes

**Default:** 100

### drilling_vertical_movement_duration

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### animation_progress

**Type:** `float`

**Optional:** Yes

**Default:** 1

### water_reflection

Only loaded if this graphics set is used in a property called `graphics_set`, refer to [EntityPrototype::water_reflection](prototype:EntityPrototype::water_reflection).

**Type:** `WaterReflectionDefinition`

**Optional:** Yes

