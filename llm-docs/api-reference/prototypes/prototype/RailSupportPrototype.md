# RailSupportPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `rail-support`

## Properties

### graphics_set

**Type:** `RailSupportGraphicsSet`

**Required:** Yes

### support_range

Must be lower than 500 and at least 1.

**Type:** `float`

**Optional:** Yes

**Default:** 15.0

### not_buildable_if_no_rails

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### snap_to_spots_distance

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### collision_mask_allow_on_deep_oil_ocean

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"rail-support/allow_on_deep_oil_ocean"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### elevated_selection_boxes

Array must contain 8 items.

**Type:** Array[`BoundingBox`]

**Optional:** Yes

### build_grid_size

Has to be 2 for 2x2 grid.

**Type:** `2`

**Optional:** Yes

**Default:** 2

**Overrides parent:** Yes

### name

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

Requires Space Age to create prototypes with name not starting with `dummy-`. Dummy prototypes cannot be built.

**Type:** `string`

**Required:** Yes

**Overrides parent:** Yes

