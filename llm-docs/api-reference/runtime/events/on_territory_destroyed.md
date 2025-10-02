# on_territory_destroyed

Called when a territory is destroyed from a surface.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### territory

**Type:** `LuaTerritory`

The territory that will be destroyed. This object will be valid so that you can still read and modify its properties before it is finally destroyed.

### tick

**Type:** `uint`

Tick the event was generated.

