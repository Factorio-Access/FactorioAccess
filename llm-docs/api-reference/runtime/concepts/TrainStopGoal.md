# TrainStopGoal

**Type:** Table

## Parameters

### priority

Goal priority. If not provided, defaults to [LuaEntity::train_stop_priority](runtime:LuaEntity::train_stop_priority) of provided train_stop.

**Type:** `uint8`

**Optional:** Yes

### train_stop

Train stop target. Must be connected to rail ([LuaEntity::connected_rail](runtime:LuaEntity::connected_rail) returns valid LuaEntity).

**Type:** `LuaEntity`

**Required:** Yes

