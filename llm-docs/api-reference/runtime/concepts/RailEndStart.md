# RailEndStart

**Type:** Table

## Parameters

### allow_path_within_segment

Defaults to `true`. Providing false will cause the pathfinder to reject a path that starts here and ends in the same segment as the path would be too short to provide correct alignment with a goal.

**Type:** `boolean`

**Optional:** Yes

### direction

**Type:** `defines.rail_direction`

**Required:** Yes

### is_front

Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### priority

Start priority. Defaults to `50`.

**Type:** `uint8`

**Optional:** Yes

### rail

**Type:** `LuaEntity`

**Required:** Yes

