# TriggerItem

**Type:** Table

## Parameters

### action_delivery

**Type:** Array[`TriggerDelivery`]

**Optional:** Yes

### collision_mask

The trigger will only affect entities that would collide with given collision mask.

**Type:** `CollisionMask`

**Required:** Yes

### entity_flags

The trigger will only affect entities that contain any of these flags.

**Type:** `EntityPrototypeFlags`

**Optional:** Yes

### force

If `"enemy"`, the trigger will only affect entities whose force is different from the attacker's and for which there is no cease-fire set. `"ally"` is the opposite of `"enemy"`.

**Type:** `ForceCondition`

**Required:** Yes

### ignore_collision_condition

**Type:** `boolean`

**Required:** Yes

### probability

**Type:** `float`

**Required:** Yes

### repeat_count

**Type:** `uint32`

**Required:** Yes

### trigger_target_mask

**Type:** `TriggerTargetMask`

**Required:** Yes

### type

**Type:** `"direct"` | `"area"` | `"line"` | `"cluster"`

**Required:** Yes

