# RailSignalBasePrototype

The abstract base entity for both rail signals.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### elevated_picture_set

**Type:** `RailSignalPictureSet`



#### ground_picture_set

**Type:** `RailSignalPictureSet`



### Optional Properties

#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### collision_box

**Type:** `BoundingBox`

The [collision_box](prototype:EntityPrototype::collision_box) of rail signals is hardcoded to `{{-0.2, -0.2}, {0.2, 0.2}}`.

**Default:** ``{{-0.2, -0.2}, {0.2, 0.2}}``

#### default_blue_output_signal

**Type:** `SignalIDConnector`



#### default_green_output_signal

**Type:** `SignalIDConnector`



#### default_orange_output_signal

**Type:** `SignalIDConnector`



#### default_red_output_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### elevated_collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/elevated"`.

#### elevated_selection_priority

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 55}`

#### flags

**Type:** `EntityPrototypeFlags`

The "placeable-off-grid" flag will be ignored for rail signals.

