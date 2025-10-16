# NeighbourConnectableConnectionDefinition

In order for 2 NeighbourConnectable to connect they need to share a connection point at the same position with opposite direction and both accept neighbor's category.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### location

**Type:** `MapLocation`

**Required:** Yes

### category

Name of a category this connection should belong to. Used when deciding which connections are allowed to connect to this.

Cannot be an empty string.

**Type:** `NeighbourConnectableConnectionCategory`

**Required:** Yes

### neighbour_category

Table of neighbor categories this connection will connect to.

**Type:** Array[`NeighbourConnectableConnectionCategory`]

**Optional:** Yes

