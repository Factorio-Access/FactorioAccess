# LuaTrain

A train. Trains are a sequence of connected rolling stocks -- locomotives and wagons.

## Methods

### clear_fluids_inside

Clears all fluids in this train.

### clear_items_inside

Clear all items in this train.

### get_contents

Get a mapping of the train's inventory.

**Returns:**

- ``ItemWithQualityCounts`[]`: List of all items in the train.

### get_fluid_contents

Gets a mapping of the train's fluid inventory.

**Returns:**

- `dictionary<`string`, `double`>`: The counts, indexed by fluid names.

### get_fluid_count

Get the amount of a particular fluid stored in the train.

**Parameters:**

- `fluid` `string` _(optional)_: Fluid name to count. If not given, counts all fluids.

**Returns:**

- `double`: 

### get_item_count

Get the amount of a particular item stored in the train.

**Parameters:**

- `item` `ItemFilter` _(optional)_: If not given, counts all items.

**Returns:**

- `uint`: 

### get_rail_end

Gets a LuaRailEnd object pointing away from the train at specified end of the train

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `LuaRailEnd`: 

### get_rails

Gets all rails under the train.

**Returns:**

- ``LuaEntity`[]`: 

### get_schedule



**Returns:**

- `LuaSchedule`: 

### go_to_station

Go to the station specified by the index in the train's schedule.

**Parameters:**

- `index` `uint`: 

### insert

Insert a stack into the train.

**Parameters:**

- `stack` `ItemStackIdentification`: 

### insert_fluid

Inserts the given fluid into the first available location in this train.

**Parameters:**

- `fluid` `Fluid`: 

**Returns:**

- `double`: The amount inserted.

### recalculate_path

Checks if the path is invalid and tries to re-path if it isn't.

**Parameters:**

- `force` `boolean` _(optional)_: Forces the train to re-path regardless of the current path being valid or not.

**Returns:**

- `boolean`: If the train has a path after the repath attempt.

### remove_fluid

Remove some fluid from the train.

**Parameters:**

- `fluid` `Fluid`: 

**Returns:**

- `double`: The amount of fluid actually removed.

### remove_item

Remove some items from the train.

**Parameters:**

- `stack` `ItemStackIdentification`: The amount and type of items to remove

**Returns:**

- `uint`: Number of items actually removed.

## Attributes

### back_end

**Type:** `LuaRailEnd` _(read-only)_

Back end of the train: Rail and direction on that rail where the train will go when moving backward

### back_stock

**Type:** `LuaEntity` _(read-only)_

The back stock of this train, if any. The back of the train is at the opposite end of the [front](runtime:LuaTrain::front_stock).

### cargo_wagons

**Type:** ``LuaEntity`[]` _(read-only)_

The cargo carriages the train contains.

### carriages

**Type:** ``LuaEntity`[]` _(read-only)_

The rolling stocks this train is composed of, with the numbering starting at the [front](runtime:LuaTrain::front_stock) of the train.

### fluid_wagons

**Type:** ``LuaEntity`[]` _(read-only)_

The fluid carriages the train contains.

### front_end

**Type:** `LuaRailEnd` _(read-only)_

Front end of the train: Rail and direction on that rail where the train will go when moving forward

### front_stock

**Type:** `LuaEntity` _(read-only)_

The front stock of this train, if any. The front of the train is in the direction that a majority of locomotives are pointing in. If it's a tie, the North and West directions take precedence.

### group

**Type:** `string`

The group this train belongs to.

Setting the group will apply the schedule of the group to this train.

### has_path

**Type:** `boolean` _(read-only)_

If this train has a path.

### id

**Type:** `uint` _(read-only)_

The unique train ID.

### kill_count

**Type:** `uint` _(read-only)_

The total number of kills by this train.

### killed_players

**Type:** `dictionary<`uint`, `uint`>` _(read-only)_

The players killed by this train.

The keys are the player indices, the values are how often this train killed that player.

### locomotives

**Type:** `unknown` _(read-only)_

Locomotives of the train.

### manual_mode

**Type:** `boolean`

When `true`, the train is explicitly controlled by the player or script. When `false`, the train moves autonomously according to its schedule.

### max_backward_speed

**Type:** `double` _(read-only)_

Current max speed when moving backwards, depends on locomotive prototype and fuel.

### max_forward_speed

**Type:** `double` _(read-only)_

Current max speed when moving forward, depends on locomotive prototype and fuel.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### passengers

**Type:** ``LuaPlayer`[]` _(read-only)_

The player passengers on the train

This does *not* index using player index. See [LuaPlayer::index](runtime:LuaPlayer::index) on each player instance for the player index.

### path

**Type:** `LuaRailPath` _(read-only)_

The path this train is using, if any.

### path_end_rail

**Type:** `LuaEntity` _(read-only)_

The destination rail this train is currently pathing to, if any.

### path_end_stop

**Type:** `LuaEntity` _(read-only)_

The destination train stop this train is currently pathing to, if any.

### riding_state

**Type:** `RidingState` _(read-only)_

The riding state of this train.

### schedule

**Type:** `TrainSchedule`

This train's current schedule, if any. Set to `nil` to clear.

The schedule can't be changed by modifying the returned table. Instead, changes must be made by assigning a new table to this attribute.

### signal

**Type:** `LuaEntity` _(read-only)_

The signal this train is arriving or waiting at, if any.

### speed

**Type:** `double`

Current speed.

Changing the speed of the train is potentially an unsafe operation because train uses the speed for its internal calculations of break distances, etc.

### state

**Type:** `defines.train_state` _(read-only)_

This train's current state.

### station

**Type:** `LuaEntity` _(read-only)_

The train stop this train is stopped at, if any.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### weight

**Type:** `double` _(read-only)_

The weight of this train.

