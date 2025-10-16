# ScheduleRecord

**Type:** Table

## Parameters

### allows_unloading

**Type:** `boolean`

**Optional:** Yes

### created_by_interrupt

**Type:** `boolean`

**Optional:** Yes

### rail

**Type:** `LuaEntity`

**Optional:** Yes

### rail_direction

When a train is allowed to reach rail target from any direction it will be `nil`. If rail has to be reached from specific direction, this value allows to choose the direction. This value corresponds to [LuaEntity::connected_rail_direction](runtime:LuaEntity::connected_rail_direction) of a TrainStop.

**Type:** `defines.rail_direction`

**Optional:** Yes

### station

Name of the station.

**Type:** `string`

**Optional:** Yes

### temporary

**Type:** `boolean`

**Optional:** Yes

### wait_conditions

**Type:** Array[`WaitCondition`]

**Optional:** Yes

