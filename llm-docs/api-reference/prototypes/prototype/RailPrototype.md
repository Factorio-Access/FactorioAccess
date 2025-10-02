# RailPrototype

The abstract base of all rail prototypes.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### walking_sound

Sound played when a character walks over this rail.

**Type:** `Sound`

**Optional:** Yes

### pictures

**Type:** `RailPictureSet`

**Required:** Yes

### fence_pictures

**Type:** `RailFenceGraphicsSet`

**Optional:** Yes

### extra_planner_penalty

**Type:** `double`

**Optional:** Yes

**Default:** 0

### extra_planner_goal_penalty

**Type:** `double`

**Optional:** Yes

**Default:** 0

### forced_fence_segment_count

Must be 0, 2 or 4. Can't be non-zero if `fence_pictures` is defined.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### ending_shifts

**Type:** Array[`Vector`]

**Optional:** Yes

### deconstruction_marker_positions

**Type:** Array[`Vector`]

**Optional:** Yes

### removes_soft_decoratives

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### build_grid_size

Has to be 2 for 2x2 grid.

**Type:** `2`

**Optional:** Yes

**Default:** 2

**Overrides parent:** Yes

### selection_box

The rail [selection_boxes](prototype:EntityPrototype::selection_box) are automatically calculated from the collision boxes, which are hardcoded. So effectively the selection boxes also hardcoded.

**Type:** `BoundingBox`

**Optional:** Yes

**Overrides parent:** Yes

