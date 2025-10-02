# WorkingVisualisations

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### animation

**Type:** `Animation4Way`

**Optional:** Yes

### idle_animation

Idle animation must have the same frame count as animation.

**Type:** `Animation4Way`

**Optional:** Yes

### always_draw_idle_animation

Only loaded if `idle_animation` is defined.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### default_recipe_tint

**Type:** `GlobalRecipeTints`

**Optional:** Yes

### recipe_not_set_tint

**Type:** `GlobalRecipeTints`

**Optional:** Yes

### states

At least 2 visual states must be defined or no states at all. At most 32 states may be defined.

**Type:** Array[`VisualState`]

**Optional:** Yes

### working_visualisations

Used to display different animations when the machine is running, for example tinted based on the current recipe.

**Type:** Array[`WorkingVisualisation`]

**Optional:** Yes

### shift_animation_waypoints

Only loaded if one of `shift_animation_waypoint_stop_duration` or `shift_animation_transition_duration` is not 0.

**Type:** `ShiftAnimationWaypoints`

**Optional:** Yes

### shift_animation_waypoint_stop_duration

Only loaded if `shift_animation_waypoints` is defined.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### shift_animation_transition_duration

Only loaded if `shift_animation_waypoints` is defined.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### status_colors

Used by [WorkingVisualisation::apply_tint](prototype:WorkingVisualisation::apply_tint).

**Type:** `StatusColors`

**Optional:** Yes

