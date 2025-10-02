# LuaTrain

A train. Trains are a sequence of connected rolling stocks -- locomotives and wagons.

## Attributes

### manual_mode

When `true`, the train is explicitly controlled by the player or script. When `false`, the train moves autonomously according to its schedule.

**Read type:** `boolean`

**Write type:** `boolean`

### speed

Current speed.

Changing the speed of the train is potentially an unsafe operation because train uses the speed for its internal calculations of break distances, etc.

**Read type:** `double`

**Write type:** `double`

### max_forward_speed

Current max speed when moving forward, depends on locomotive prototype and fuel.

**Read type:** `double`

### max_backward_speed

Current max speed when moving backwards, depends on locomotive prototype and fuel.

**Read type:** `double`

### weight

The weight of this train.

**Read type:** `double`

### carriages

The rolling stocks this train is composed of, with the numbering starting at the [front](runtime:LuaTrain::front_stock) of the train.

**Read type:** Array[`LuaEntity`]

### locomotives

Locomotives of the train.

**Read type:** Table (see below for parameters)

### cargo_wagons

The cargo carriages the train contains.

**Read type:** Array[`LuaEntity`]

### fluid_wagons

The fluid carriages the train contains.

**Read type:** Array[`LuaEntity`]

### schedule

This train's current schedule, if any. Set to `nil` to clear.

The schedule can't be changed by modifying the returned table. Instead, changes must be made by assigning a new table to this attribute.

**Read type:** `TrainSchedule`

**Write type:** `TrainSchedule`

**Optional:** Yes

### state

This train's current state.

**Read type:** `defines.train_state`

### front_stock

The front stock of this train, if any. The front of the train is in the direction that a majority of locomotives are pointing in. If it's a tie, the North and West directions take precedence.

**Read type:** `LuaEntity`

**Optional:** Yes

### back_stock

The back stock of this train, if any. The back of the train is at the opposite end of the [front](runtime:LuaTrain::front_stock).

**Read type:** `LuaEntity`

**Optional:** Yes

### station

The train stop this train is stopped at, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### has_path

If this train has a path.

**Read type:** `boolean`

### path_end_rail

The destination rail this train is currently pathing to, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### path_end_stop

The destination train stop this train is currently pathing to, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### id

The unique train ID.

**Read type:** `uint`

### passengers

The player passengers on the train

This does *not* index using player index. See [LuaPlayer::index](runtime:LuaPlayer::index) on each player instance for the player index.

**Read type:** Array[`LuaPlayer`]

### riding_state

The riding state of this train.

**Read type:** `RidingState`

### killed_players

The players killed by this train.

The keys are the player indices, the values are how often this train killed that player.

**Read type:** Dictionary[`uint`, `uint`]

### kill_count

The total number of kills by this train.

**Read type:** `uint`

### path

The path this train is using, if any.

**Read type:** `LuaRailPath`

**Optional:** Yes

### signal

The signal this train is arriving or waiting at, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### group

The group this train belongs to.

Setting the group will apply the schedule of the group to this train.

**Read type:** `string`

**Write type:** `string`

### front_end

Front end of the train: Rail and direction on that rail where the train will go when moving forward

**Read type:** `LuaRailEnd`

### back_end

Back end of the train: Rail and direction on that rail where the train will go when moving backward

**Read type:** `LuaRailEnd`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_item_count

Get the amount of a particular item stored in the train.

**Parameters:**

- `item` `ItemFilter` *(optional)* - If not given, counts all items.

**Returns:**

- `uint`

### get_contents

Get a mapping of the train's inventory.

**Returns:**

- `ItemWithQualityCounts` - List of all items in the train.

### remove_item

Remove some items from the train.

**Parameters:**

- `stack` `ItemStackIdentification` - The amount and type of items to remove

**Returns:**

- `uint` - Number of items actually removed.

### insert

Insert a stack into the train.

**Parameters:**

- `stack` `ItemStackIdentification`

### clear_items_inside

Clear all items in this train.

### recalculate_path

Checks if the path is invalid and tries to re-path if it isn't.

**Parameters:**

- `force` `boolean` *(optional)* - Forces the train to re-path regardless of the current path being valid or not.

**Returns:**

- `boolean` - If the train has a path after the repath attempt.

### get_fluid_count

Get the amount of a particular fluid stored in the train.

**Parameters:**

- `fluid` `string` *(optional)* - Fluid name to count. If not given, counts all fluids.

**Returns:**

- `double`

### get_fluid_contents

Gets a mapping of the train's fluid inventory.

**Returns:**

- Dictionary[`string`, `FluidAmount`] - The counts, indexed by fluid names.

### remove_fluid

Remove some fluid from the train.

**Parameters:**

- `fluid` `Fluid`

**Returns:**

- `double` - The amount of fluid actually removed.

### insert_fluid

Inserts the given fluid into the first available location in this train.

**Parameters:**

- `fluid` `Fluid`

**Returns:**

- `double` - The amount inserted.

### clear_fluids_inside

Clears all fluids in this train.

### go_to_station

Go to the station specified by the index in the train's schedule.

**Parameters:**

- `index` `uint`

### get_rails

Gets all rails under the train.

**Returns:**

- Array[`LuaEntity`]

### get_rail_end

Gets a LuaRailEnd object pointing away from the train at specified end of the train

**Parameters:**

- `direction` `defines.rail_direction`

**Returns:**

- `LuaRailEnd`

### get_schedule

**Returns:**

- `LuaSchedule`

