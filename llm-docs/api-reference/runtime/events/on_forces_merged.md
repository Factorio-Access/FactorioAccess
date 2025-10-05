# on_forces_merged

Called after two forces have been merged using `game.merge_forces()`.

The source force is invalidated before this event is called and the name can be re-used in this event if desired.

## Event Data

### destination

**Type:** `LuaForce`

The force entities where reassigned to.

### name

**Type:** `defines.events`

Identifier of the event

### source_index

**Type:** `uint32`

The index of the destroyed force.

### source_name

**Type:** `string`

The force destroyed.

### tick

**Type:** `uint32`

Tick the event was generated.

