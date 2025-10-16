# UnitGroupSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### min_group_gathering_time

Pollution triggered group waiting time is a random time between min and max gathering time

**Type:** `uint32`

**Required:** Yes

### max_group_gathering_time

**Type:** `uint32`

**Required:** Yes

### max_wait_time_for_late_members

After the gathering is finished the group can still wait for late members, but it doesn't accept new ones anymore.

**Type:** `uint32`

**Required:** Yes

### max_group_radius

Limits for group radius (calculated by number of numbers).

**Type:** `double`

**Required:** Yes

### min_group_radius

**Type:** `double`

**Required:** Yes

### max_member_speedup_when_behind

When a member falls behind the group he can speedup up till this much of his regular speed.

**Type:** `double`

**Required:** Yes

### max_member_slowdown_when_ahead

When a member gets ahead of its group, it will slow down to at most this factor of its speed.

**Type:** `double`

**Required:** Yes

### max_group_slowdown_factor

When members of a group are behind, the entire group will slow down to at most this factor of its max speed.

**Type:** `double`

**Required:** Yes

### max_group_member_fallback_factor

If a member falls behind more than this times the group radius, the group will slow down to max_group_slowdown_factor.

**Type:** `double`

**Required:** Yes

### member_disown_distance

If a member falls behind more than this time the group radius, it will be removed from the group.

**Type:** `double`

**Required:** Yes

### tick_tolerance_when_member_arrives

**Type:** `uint32`

**Required:** Yes

### max_gathering_unit_groups

Maximum number of automatically created unit groups gathering for attack at any time.

**Type:** `uint32`

**Required:** Yes

### max_unit_group_size

Maximum size of an attack unit group. This only affects automatically-created unit groups; manual groups created through the API are unaffected.

**Type:** `uint32`

**Required:** Yes

