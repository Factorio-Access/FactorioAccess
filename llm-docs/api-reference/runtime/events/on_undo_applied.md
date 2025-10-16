# on_undo_applied

Called when the player triggers "undo".

## Event Data

### actions

**Type:** Array[`UndoRedoAction`]

The context of the undo action.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who triggered the undo action.

### tick

**Type:** `uint32`

Tick the event was generated.

