# AddRecordData

**Type:** Table

## Parameters

### allows_unloading

Defaults to `true`.

**Type:** `boolean`

**Optional:** Yes

### created_by_interrupt

Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### index

If record position is not given, the record is appended.

**Type:** `ScheduleRecordPosition`

**Optional:** Yes

### rail

**Type:** `LuaEntity`

**Optional:** Yes

### rail_direction

When `rail` is given, this can be provided to further narrow down direction from which that rail should be approached.

**Type:** `defines.rail_direction`

**Optional:** Yes

### station

One of station or rail must be given.

**Type:** `string`

**Optional:** Yes

### temporary

Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### wait_conditions

**Type:** Array[`WaitCondition`]

**Optional:** Yes

