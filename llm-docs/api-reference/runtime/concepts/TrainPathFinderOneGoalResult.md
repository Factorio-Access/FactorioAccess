# TrainPathFinderOneGoalResult

**Type:** Table

## Parameters

### found_path

True if found path.

**Type:** `boolean`

**Required:** Yes

### goal_index

If path was found, provides index of the specific goal to which the path goes to.

**Type:** `uint`

**Optional:** Yes

### is_front

If path was found, tells if the path was reached from the train's front end or from [RailEndStart](runtime:RailEndStart) with [RailEndStart::is_front](runtime:RailEndStart::is_front) set.

**Type:** `boolean`

**Optional:** Yes

### path

Only if search was of type `"path"`, `return_path` was set to true and path was found. Contains all rails in order that are part of the found path.

**Type:** Array[`LuaEntity`]

**Optional:** Yes

### penalty

Penalty of the path to goal if path was found.

**Type:** `double`

**Optional:** Yes

### start_index

If path was found, provides index of the specific start from which the path to target goes from

**Type:** `uint`

**Optional:** Yes

### steps_count

Amount of steps pathfinder performed. This is a measure of how expensive this search was.

**Type:** `uint`

**Required:** Yes

### total_length

If path was found and search was of type `"path"`, provides total length of all rails of the path.

**Type:** `double`

**Optional:** Yes

