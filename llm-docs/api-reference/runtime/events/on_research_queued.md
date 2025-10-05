# on_research_queued

Called when research is queued.

## Event Data

### force

**Type:** `LuaForce`

The force whose research was queued.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player who queued the research if any.

### research

**Type:** `LuaTechnology`

The technology queued

### tick

**Type:** `uint32`

Tick the event was generated.

