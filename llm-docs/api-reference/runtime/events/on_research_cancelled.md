# on_research_cancelled

Called when research is cancelled.

## Event Data

### force

**Type:** `LuaForce`

The force whose research was cancelled.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player who cancelled the research if any.

### research

**Type:** Dictionary[`string`, `uint32`]

A mapping of technology name to how many times it was cancelled.

### tick

**Type:** `uint32`

Tick the event was generated.

