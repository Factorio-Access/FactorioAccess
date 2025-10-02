# on_forces_merging

Called when two forces are about to be merged using `game.merge_forces()`.

## Event Data

### destination

**Type:** `LuaForce`

The force to reassign entities to.

### name

**Type:** `defines.events`

Identifier of the event

### source

**Type:** `LuaForce`

The force to be destroyed

### tick

**Type:** `uint`

Tick the event was generated.

