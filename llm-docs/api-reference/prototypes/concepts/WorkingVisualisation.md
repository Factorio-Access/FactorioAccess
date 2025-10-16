# WorkingVisualisation

Used by crafting machines to display different graphics when the machine is running.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### fadeout

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### synced_fadeout

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### constant_speed

Whether the animations are always played at the same speed, not adjusted to the machine speed.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### always_draw

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### animated_shift

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### align_to_waypoint

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### mining_drill_scorch_mark

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### secondary_draw_order

Used to determine render order for sprites with the same `render_layer` in the same position. Sprites with a higher `secondary_draw_order` are drawn on top.

**Type:** `int8`

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### effect

**Type:** `"flicker"` | `"uranium-glow"` | `"none"`

**Optional:** Yes

### apply_recipe_tint

Used by [CraftingMachinePrototype](prototype:CraftingMachinePrototype). Has precedence over `apply_tint`.

**Type:** `"primary"` | `"secondary"` | `"tertiary"` | `"quaternary"` | `"none"`

**Optional:** Yes

### apply_tint

Used by [CraftingMachinePrototype](prototype:CraftingMachinePrototype) ("status" and "visual-state-color" only) and [MiningDrillPrototype](prototype:MiningDrillPrototype).

For "status" on CraftingMachine and MiningDrill, the colors are specified via [WorkingVisualisations::status_colors](prototype:WorkingVisualisations::status_colors). For "resource-color", the colors are specified via [ResourceEntityPrototype::mining_visualisation_tint](prototype:ResourceEntityPrototype::mining_visualisation_tint).

**Type:** `"resource-color"` | `"input-fluid-base-color"` | `"input-fluid-flow-color"` | `"status"` | `"none"` | `"visual-state-color"`

**Optional:** Yes

### north_animation

**Type:** `Animation`

**Optional:** Yes

### east_animation

**Type:** `Animation`

**Optional:** Yes

### south_animation

**Type:** `Animation`

**Optional:** Yes

### west_animation

**Type:** `Animation`

**Optional:** Yes

### north_position

**Type:** `Vector`

**Optional:** Yes

### east_position

**Type:** `Vector`

**Optional:** Yes

### south_position

**Type:** `Vector`

**Optional:** Yes

### west_position

**Type:** `Vector`

**Optional:** Yes

### north_secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** "Value of `secondary_draw_order`"

### east_secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** "Value of `secondary_draw_order`"

### south_secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** "Value of `secondary_draw_order`"

### west_secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** "Value of `secondary_draw_order`"

### north_fog_mask

If defined, animation in this visualisation layer will be used only as mask for fog effect and will not render in world.

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

### east_fog_mask

If defined, animation in this visualisation layer will be used only as mask for fog effect and will not render in world.

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

### south_fog_mask

If defined, animation in this visualisation layer will be used only as mask for fog effect and will not render in world.

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

### west_fog_mask

If defined, animation in this visualisation layer will be used only as mask for fog effect and will not render in world.

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

### fog_mask

Loaded only if at least one of north_fog_mask, east_fog_mask, south_fog_mask, west_fog_mask is not specified.

If defined, animation in this visualisation layer will be used only as mask for fog effect and will not render in world.

**Type:** `FogMaskShapeDefinition`

**Optional:** Yes

### animation

**Type:** `Animation`

**Optional:** Yes

### draw_in_states

Only loaded if [WorkingVisualisations::states](prototype:WorkingVisualisations::states) is defined in the WorkingVisualisations that loads this.

**Type:** Array[`string`]

**Optional:** Yes

### draw_when_state_filter_matches

Only loaded if [WorkingVisualisations::states](prototype:WorkingVisualisations::states) is defined in the WorkingVisualisations that loads this.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### enabled_by_name

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### name

**Type:** `string`

**Optional:** Yes

**Default:** ""

### enabled_in_animated_shift_during_waypoint_stop

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### enabled_in_animated_shift_during_transition

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### frame_based_on_shift_animation_progress

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scorch_mark_fade_out_duration

Only loaded, and mandatory if `mining_drill_scorch_mark` is `true`. Cannot be larger than `scorch_mark_lifetime`.

**Type:** `uint16`

**Optional:** Yes

### scorch_mark_lifetime

Only loaded, and mandatory if `mining_drill_scorch_mark` is `true`.

**Type:** `uint16`

**Optional:** Yes

### scorch_mark_fade_in_frames

Only loaded, and mandatory if `mining_drill_scorch_mark` is `true`.

**Type:** `uint8`

**Optional:** Yes

