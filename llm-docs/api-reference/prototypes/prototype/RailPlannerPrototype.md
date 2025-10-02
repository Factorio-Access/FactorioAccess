# RailPlannerPrototype

A [rail planner](https://wiki.factorio.com/Rail_planner).

**Parent:** [ItemPrototype](ItemPrototype.md)
**Type name:** `rail-planner`

## Properties

### rails

May not be an empty array. Entities must be rails and their first item-to-place must be this item.

**Type:** Array[`EntityID`]

**Required:** Yes

### support

Name of a rail support.

**Type:** `EntityID`

**Optional:** Yes

### manual_length_limit

**Type:** `double`

**Optional:** Yes

**Default:** "8 * 2 + 1.41 + 0.5"

