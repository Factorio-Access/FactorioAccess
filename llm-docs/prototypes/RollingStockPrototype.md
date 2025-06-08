# RollingStockPrototype

The abstract base of all rolling stock.

**Parent:** `VehiclePrototype`

## Properties

### Mandatory Properties

#### air_resistance

**Type:** `double`



#### connection_distance

**Type:** `double`

The distance between the joint of this rolling stock and its connected rolling stocks joint.

Maximum connection distance is 15.

#### joint_distance

**Type:** `double`

The length between this rolling stocks front and rear joints. Joints are the point where connection_distance is measured from when rolling stock are connected to one another. Wheels sprite are placed based on the joint position.

Maximum joint distance is 15.

Note: There needs to be border at least 0.2 between the [bounding box](prototype:EntityPrototype::collision_box) edge and joint. This means that the collision_box must be at least `{{-0,-0.2},{0,0.2}}`.

#### max_speed

**Type:** `double`

Maximum speed of the rolling stock in tiles/tick.

In-game, the max speed of a train is `min(all_rolling_stock_max_speeds) × average(all_fuel_modifiers_in_all_locomotives)`. This calculated train speed is then silently capped to 7386.3km/h.

#### vertical_selection_shift

**Type:** `double`



### Optional Properties

#### allow_manual_color

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### allow_robot_dispatch_in_automatic_mode

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### back_light

**Type:** `LightDefinition`



#### color

**Type:** `Color`



#### default_copy_color_from_train_stop

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### door_closing_sound

**Type:** `InterruptibleSound`

Cannot use `fade_ticks`.

#### door_opening_sound

**Type:** `InterruptibleSound`

Cannot use `fade_ticks`.

#### drive_over_elevated_tie_trigger

**Type:** `TriggerEffect`



#### drive_over_tie_trigger

**Type:** `TriggerEffect`

Usually a sound to play when the rolling stock drives over a tie. The rolling stock is considered to be driving over a tie every `tie_distance` tiles.

#### drive_over_tie_trigger_minimal_speed

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### elevated_collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/elevated"`.

#### elevated_rail_sound

**Type:** `MainSound`



#### elevated_selection_priority

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 56}`

#### horizontal_doors

**Type:** `Animation`



#### pictures

**Type:** `RollingStockRotatedSlopedGraphics`



#### stand_by_light

**Type:** `LightDefinition`



#### tie_distance

**Type:** `double`

In tiles. Used to determine how often `drive_over_tie_trigger` is triggered.

**Default:** `{'complex_type': 'literal', 'value': 10.0}`

#### transition_collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by  `type .. "/transition"`.

#### vertical_doors

**Type:** `Animation`



#### wheels

**Type:** `RollingStockRotatedSlopedGraphics`



