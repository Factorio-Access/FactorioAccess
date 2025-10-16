# on_force_created

Called when a new force is created using `game.create_force()`

This is not called when the default forces (`'player'`, `'enemy'`, `'neutral'`) are created as they will always exist.

## Event Data

### force

**Type:** `LuaForce`

The newly created force.

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint32`

Tick the event was generated.

