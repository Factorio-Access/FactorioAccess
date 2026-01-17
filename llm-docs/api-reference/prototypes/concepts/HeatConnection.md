# HeatConnection

Defines the connections for [HeatEnergySource](prototype:HeatEnergySource) and [HeatBuffer](prototype:HeatBuffer).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### position

The location of the heat pipe connection, relative to the center of the entity in the north-facing direction.

**Type:** `MapPosition`

**Required:** Yes

### direction

The "outward" direction of this heat connection. For a connection to succeed, the other heat connection must face the opposite direction (a south-facing connection needs a north-facing connection to succeed). A connection rotates with the entity.

**Type:** `defines.direction`

**Required:** Yes

