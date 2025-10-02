# on_research_moved

Called when research is moved forwards or backwards in the research queue.

## Event Data

### force

**Type:** `LuaForce`

The force whose research was re-arranged.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player who did the re-arranging if any.

### tick

**Type:** `uint`

Tick the event was generated.

