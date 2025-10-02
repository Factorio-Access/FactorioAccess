# UnitGroupMapSettings

**Type:** Table

## Parameters

### max_gathering_unit_groups

The maximum number of automatically created unit groups gathering for attack at any time. Defaults to `30`.

**Type:** `uint`

**Required:** Yes

### max_group_gathering_time

The maximum amount of time in ticks a group will spend gathering before setting off. The actual time is a random time between the minimum and maximum times. Defaults to `10*3 600=36 000` ticks.

**Type:** `uint`

**Required:** Yes

### max_group_member_fallback_factor

When a member of a group falls back more than this factor times the group radius, the group will slow down to its `max_group_slowdown_factor` speed to let them catch up. Defaults to `3`.

**Type:** `double`

**Required:** Yes

### max_group_radius

The maximum group radius in tiles. The actual radius is adjusted based on the number of members. Defaults to `30.0`.

**Type:** `double`

**Required:** Yes

### max_group_slowdown_factor

The minimum speed as a percentage of its maximum speed that a group will slow down to so members that fell behind can catch up. Defaults to `0.3`, or 30%.

**Type:** `double`

**Required:** Yes

### max_member_slowdown_when_ahead

The minimum speed a percentage of its regular speed that a group member can slow down to when ahead of the group. Defaults to `0.6`, or 60%.

**Type:** `double`

**Required:** Yes

### max_member_speedup_when_behind

The maximum speed a percentage of its regular speed that a group member can speed up to when catching up with the group. Defaults to `1.4`, or 140%.

**Type:** `double`

**Required:** Yes

### max_unit_group_size

The maximum number of members for an attack unit group. This only affects automatically created unit groups, manual groups created through the API are unaffected. Defaults to `200`.

**Type:** `uint`

**Required:** Yes

### max_wait_time_for_late_members

After gathering has finished, the group is allowed to wait this long in ticks for delayed members. New members are not accepted anymore however. Defaults to `2*3 600=7 200` ticks.

**Type:** `uint`

**Required:** Yes

### member_disown_distance

When a member of a group falls back more than this factor times the group radius, it will be dropped from the group. Defaults to `10`.

**Type:** `double`

**Required:** Yes

### min_group_gathering_time

The minimum amount of time in ticks a group will spend gathering before setting off. The actual time is a random time between the minimum and maximum times. Defaults to `3 600` ticks.

**Type:** `uint`

**Required:** Yes

### min_group_radius

The minimum group radius in tiles. The actual radius is adjusted based on the number of members. Defaults to `5.0`.

**Type:** `double`

**Required:** Yes

### tick_tolerance_when_member_arrives

**Type:** `uint`

**Required:** Yes

