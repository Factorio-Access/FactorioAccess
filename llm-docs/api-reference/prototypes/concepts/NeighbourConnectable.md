# NeighbourConnectable

Defines how this entity connects to its neighbours

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### affected_by_direction

If the connection positions and directions will be affected by entity's direction.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### neighbour_search_distance

Distance by which connection point is shifted along its direction to select a position where neighbor will be searched.

**Type:** `float`

**Optional:** Yes

**Default:** 0.7

### connections

Definitions of the connection points.

**Type:** Array[`NeighbourConnectableConnectionDefinition`]

**Required:** Yes

