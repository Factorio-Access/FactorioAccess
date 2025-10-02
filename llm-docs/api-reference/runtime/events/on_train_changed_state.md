# on_train_changed_state

Called when a train changes state (started to stopped and vice versa)

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### old_state

**Type:** `defines.train_state`

### tick

**Type:** `uint`

Tick the event was generated.

### train

**Type:** `LuaTrain`

