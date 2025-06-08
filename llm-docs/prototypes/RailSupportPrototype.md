# RailSupportPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### graphics_set

**Type:** `RailSupportGraphicsSet`



### Optional Properties

#### build_grid_size

**Type:** `2`

Has to be 2 for 2x2 grid.

**Default:** `{'complex_type': 'literal', 'value': 2}`

#### collision_mask_allow_on_deep_oil_ocean

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"allow_on_deep_oil_ocean"`.

#### elevated_selection_boxes

**Type:** ``BoundingBox`[]`

Array must contain 8 items.

#### not_buildable_if_no_rails

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### snap_to_spots_distance

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### support_range

**Type:** `float`

Must be lower than 500 and at least 1.

**Default:** `{'complex_type': 'literal', 'value': 15.0}`

