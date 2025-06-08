# RailRampPrototype

A rail ramp.

**Parent:** `RailPrototype`

## Properties

### Optional Properties

#### collision_box

**Type:** `BoundingBox`

The [collision_box](prototype:EntityPrototype::collision_box) of straight rail is hardcoded to `{{-1.6, -7.6}, {1.6, 7.6}}`.

**Default:** ``{{-1.6, -7.6}, {1.6, 7.6}}``

#### collision_mask_allow_on_deep_oil_ocean

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"allow_on_deep_oil_ocean"`.

#### support_range

**Type:** `float`

Must be lower than 500 and at least 1.

**Default:** `{'complex_type': 'literal', 'value': 15.0}`

