# SpiderEngineSpecification

Used by [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### legs

**Type:** `SpiderLegSpecification` | Array[`SpiderLegSpecification`]

**Required:** Yes

### walking_group_overlap

The amount of overlap allowed between spider leg walking groups. Valid values are between 0.0 and 1.0. Default is 0.0 (no overlap); all legs in the current walking group must complete their step before the next walking group is allowed to move. 0.5 means the next walking group is allowed to start when the time remaining in the current walking group's step is about half of the time that the next group's step is predicted to take.

**Type:** `float`

**Optional:** Yes

**Default:** 0

