# LuaTrainManager

The train manager manages all the train in the game. LuaTrainManager allows to perform some direct queries to the train manager.

There is always exactly one train manager instance in a game, it can be obtained from [LuaGameScript::train_manager](runtime:LuaGameScript::train_manager). This object is always valid and is equal to any other instance of LuaTrainManager from this game.

## Attributes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_train_by_id

Searches for a train with given ID.

**Parameters:**

- `train_id` `uint32` - Train ID to search

**Returns:**

- `LuaTrain` *(optional)* - Train if found

### get_trains

Gets all trains that pass given filter

**Parameters:**

- `filter` `TrainFilter` - Filters the train must pass in order to be returned here

**Returns:**

- Array[`LuaTrain`]

### get_train_stops

Gets all train stops that pass given filter

**Parameters:**

- `filter` `TrainStopFilter` - Filters the train stop must pass in order to be returned here

**Returns:**

- Array[`LuaEntity`]

### request_train_path

Direct access to train pathfinder. Allows to search rail paths or querying which stops are accessible

**Parameters:**

- `type` `TrainPathRequestType` *(optional)* - Request type. Determines the return type of the method. Defaults to `"path"`.
- `train` `LuaTrain` *(optional)* - Mandatory if `starts` is not provided, optional otherwise. Selects a context for the pathfinder to decide which train to exclude from penalties and which signals are considered possible to reacquire. If `starts` is not provided, then it is also used to collect front and back ends for the search
- `goals` Array[`TrainPathFinderGoal`]
- `return_path` `boolean` *(optional)* - Only relevant if request type is `"path"`. Returning a full path is expensive due to multiple LuaEntity created. In order for path to be returned, true must be provided here. Defaults to false in which case a path will not be provided.
- `starts` Array[`RailEndStart`] *(optional)* - Manually provided starting positions.
- `search_direction` `"respect-movement-direction"` | `"any-direction-with-locomotives"` *(optional)* - Only relevant if `starts` was not provided in which case 2 starts (front and back) are deduced from the train. Selects which train ends should be considered as starts. Defaults to `"any-direction-with-locomotives"`.
- `in_chain_signal_section` `boolean` *(optional)* - Defaults to `false`. If set to true, pathfinder will not return a path that cannot have its start immediately reserved. A path that cannot have its start immediately reserved could cause a train to stop inside of an intersection.
- `steps_limit` `uint32` *(optional)* - Maximum amount of steps pathfinder is allowed to perform.
- `shortest_path` `boolean` *(optional)* - Defaults to `false`. If set to true, only length of rails is added to penalties causing search to look for shortest path (not smallest penalty)

**Returns:**

- `TrainPathFinderOneGoalResult` | `TrainPathAllGoalsResult` - The type of the returned value depends on `type`.

