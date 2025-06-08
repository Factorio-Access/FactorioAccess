# RailPlannerPrototype

A [rail planner](https://wiki.factorio.com/Rail_planner).

**Parent:** `ItemPrototype`

## Properties

### Mandatory Properties

#### rails

**Type:** ``EntityID`[]`

May not be an empty array. Entities must be rails and their first item-to-place must be this item.

### Optional Properties

#### manual_length_limit

**Type:** `double`



**Default:** `8 * 2 + 1.41 + 0.5`

#### support

**Type:** `EntityID`

Name of a rail support.

