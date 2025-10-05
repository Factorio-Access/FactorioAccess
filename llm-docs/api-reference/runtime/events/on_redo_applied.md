# on_redo_applied

Called when the player triggers "redo".

## Event Data

### actions

**Type:** Array[`UndoRedoAction`]

The context of the redo action.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who triggered the redo action.

### tick

**Type:** `uint32`

Tick the event was generated.

