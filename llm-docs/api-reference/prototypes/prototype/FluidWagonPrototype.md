# FluidWagonPrototype

A [fluid wagon](https://wiki.factorio.com/Fluid_wagon).

**Parent:** [RollingStockPrototype](RollingStockPrototype.md)
**Type name:** `fluid-wagon`

## Properties

### capacity

**Type:** `FluidAmount`

**Required:** Yes

### quality_affects_capacity

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tank_count

Must be 1, 2 or 3.

**Type:** `uint8`

**Optional:** Yes

**Default:** 3

### connection_category

Pumps are only allowed to connect to this fluid wagon if the pump's [fluid box connection](prototype:PipeConnectionDefinition) and this fluid wagon share a connection category. Pump may have different connection categories on the input and output side, connection categories will be taken from the connection that is facing towards fluid wagon.

**Type:** `string` | Array[`string`]

**Optional:** Yes

**Default:** "default"

