# RailRampPrototype

A rail ramp.

**Parent:** [RailPrototype](RailPrototype.md)
**Type name:** `rail-ramp`

## Properties

### support_range

Must be lower than 500 and at least 1.

**Type:** `float`

**Optional:** Yes

**Default:** 15.0

### collision_mask_allow_on_deep_oil_ocean

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"rail-ramp/allow_on_deep_oil_ocean"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### collision_box

The [collision_box](prototype:EntityPrototype::collision_box) of straight rail is hardcoded to `{{-1.6, -7.6}, {1.6, 7.6}}`.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "`{{-1.6, -7.6}, {1.6, 7.6}}`"

**Overrides parent:** Yes

### name

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

Requires Space Age to create prototypes with name not starting with `dummy-`. Dummy prototypes cannot be built.

**Type:** `string`

**Required:** Yes

**Overrides parent:** Yes

