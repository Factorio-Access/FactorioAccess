# RailPrototype

The abstract base of all rail prototypes.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### pictures

**Type:** `RailPictureSet`



### Optional Properties

#### build_grid_size

**Type:** `2`

Has to be 2 for 2x2 grid.

**Default:** `{'complex_type': 'literal', 'value': 2}`

#### deconstruction_marker_positions

**Type:** ``Vector`[]`



#### ending_shifts

**Type:** ``Vector`[]`



#### extra_planner_goal_penalty

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### extra_planner_penalty

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### fence_pictures

**Type:** `RailFenceGraphicsSet`



#### forced_fence_segment_count

**Type:** `uint8`

Must be 0, 2 or 4. Can't be non-zero if `fence_pictures` is defined.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### removes_soft_decoratives

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### selection_box

**Type:** `BoundingBox`

The rail [selection_boxes](prototype:EntityPrototype::selection_box) are automatically calculated from the collision boxes, which are hardcoded. So effectively the selection boxes also hardcoded.

#### walking_sound

**Type:** `Sound`

Sound played when a character walks over this rail.

