# PathfinderFlags

**Type:** Table

## Parameters

### allow_destroy_friendly_entities

Allows pathing through friendly entities. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### allow_paths_through_own_entities

Allows the pathfinder to path through entities of the same force. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### cache

Enables path caching. This can be more efficient, but might fail to respond to changes in the environment. Defaults to `true`.

**Type:** `boolean`

**Optional:** Yes

### low_priority

Sets lower priority on the path request, meaning it might take longer to find a path at the expense of speeding up others. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### no_break

Makes the pathfinder not break in the middle of processing this pathfind, no matter how much work is needed. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### prefer_straight_paths

Makes the pathfinder try to path in straight lines. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

