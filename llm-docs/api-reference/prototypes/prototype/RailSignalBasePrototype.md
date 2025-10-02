# RailSignalBasePrototype

The abstract base entity for both rail signals.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### ground_picture_set

**Type:** `RailSignalPictureSet`

**Required:** Yes

### elevated_picture_set

**Type:** `RailSignalPictureSet`

**Required:** Yes

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### default_red_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_orange_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_green_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_blue_output_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### elevated_collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/elevated"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### elevated_selection_priority

**Type:** `uint8`

**Optional:** Yes

**Default:** 55

### collision_box

The [collision_box](prototype:EntityPrototype::collision_box) of rail signals is hardcoded to `{{-0.2, -0.2}, {0.2, 0.2}}`.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "`{{-0.2, -0.2}, {0.2, 0.2}}`"

**Overrides parent:** Yes

### flags

The "placeable-off-grid" flag will be ignored for rail signals.

**Type:** `EntityPrototypeFlags`

**Optional:** Yes

**Overrides parent:** Yes

