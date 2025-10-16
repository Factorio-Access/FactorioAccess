# RollingStockPrototype

The abstract base of all rolling stock.

**Parent:** [VehiclePrototype](VehiclePrototype.md)
**Abstract:** Yes

## Properties

### max_speed

Maximum speed of the rolling stock in tiles/tick.

In-game, the max speed of a train is `min(all_rolling_stock_max_speeds) × average(all_fuel_modifiers_in_all_locomotives)`. This calculated train speed is then silently capped to 7386.3km/h.

**Type:** `double`

**Required:** Yes

### air_resistance

**Type:** `double`

**Required:** Yes

### joint_distance

The length between this rolling stocks front and rear joints. Joints are the point where connection_distance is measured from when rolling stock are connected to one another. Wheels sprite are placed based on the joint position.

Maximum joint distance is 15.

Note: There needs to be border at least 0.2 between the [bounding box](prototype:EntityPrototype::collision_box) edge and joint. This means that the collision_box must be at least `{{-0,-0.2},{0,0.2}}`.

**Type:** `double`

**Required:** Yes

### connection_distance

The distance between the joint of this rolling stock and its connected rolling stocks joint.

Maximum connection distance is 15.

**Type:** `double`

**Required:** Yes

### pictures

**Type:** `RollingStockRotatedSlopedGraphics`

**Optional:** Yes

### wheels

**Type:** `RollingStockRotatedSlopedGraphics`

**Optional:** Yes

### vertical_selection_shift

**Type:** `double`

**Required:** Yes

### drive_over_tie_trigger

Usually a sound to play when the rolling stock drives over a tie. The rolling stock is considered to be driving over a tie every `tie_distance` tiles.

**Type:** `TriggerEffect`

**Optional:** Yes

### drive_over_tie_trigger_minimal_speed

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### tie_distance

In tiles. Used to determine how often `drive_over_tie_trigger` is triggered.

**Type:** `double`

**Optional:** Yes

**Default:** 10.0

### back_light

**Type:** `LightDefinition`

**Optional:** Yes

### stand_by_light

**Type:** `LightDefinition`

**Optional:** Yes

### horizontal_doors

**Type:** `Animation`

**Optional:** Yes

### vertical_doors

**Type:** `Animation`

**Optional:** Yes

### color

**Type:** `Color`

**Optional:** Yes

### allow_manual_color

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_robot_dispatch_in_automatic_mode

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### default_copy_color_from_train_stop

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### transition_collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/transition"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### elevated_collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/elevated"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### elevated_selection_priority

**Type:** `uint8`

**Optional:** Yes

**Default:** 56

### elevated_rail_sound

**Type:** `MainSound`

**Optional:** Yes

### drive_over_elevated_tie_trigger

**Type:** `TriggerEffect`

**Optional:** Yes

### door_opening_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### door_closing_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

