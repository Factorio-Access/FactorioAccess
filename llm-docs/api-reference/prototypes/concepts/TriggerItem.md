# TriggerItem

The abstract base of all [Triggers](prototype:Trigger).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### entity_flags

Only prototypes with these flags are affected by the trigger item.

**Type:** `EntityPrototypeFlags`

**Optional:** Yes

**Default:** "All flags"

### collision_mask

Only prototypes with these collision masks are affected by the trigger item.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

**Default:** "All masks"

### ignore_collision_condition

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### trigger_target_mask

The trigger affects only prototypes with these masks.

**Type:** `TriggerTargetMask`

**Optional:** Yes

**Default:** "Everything"

### repeat_count

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### probability

Must be greater than 0 and less than or equal to 1.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### action_delivery

**Type:** `TriggerDelivery` | Array[`TriggerDelivery`]

**Optional:** Yes

### force

Only entities meeting the force condition are affected by the trigger item.

**Type:** `ForceCondition`

**Optional:** Yes

**Default:** "All forces"

