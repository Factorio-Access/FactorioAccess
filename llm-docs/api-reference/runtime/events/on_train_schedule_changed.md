# on_train_schedule_changed

Called when a trains schedule is changed either by the player or through script.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player who made the change if any.

### tick

**Type:** `uint32`

Tick the event was generated.

### train

**Type:** `LuaTrain`

