# EquipmentGridPrototype

The prototype of an equipment grid, for example the one used in a [power armor](https://wiki.factorio.com/Power_armor).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### equipment_categories

**Type:** ``EquipmentCategoryID`[]`

Only [equipment](prototype:EquipmentPrototype) with at least one of these [categories](prototype:EquipmentCategory) can be inserted into the grid.

#### height

**Type:** `uint32`



#### width

**Type:** `uint32`



### Optional Properties

#### locked

**Type:** `boolean`

Whether this locked from user interaction which means that the user cannot put equipment into or take equipment from this equipment grid.

**Default:** `{'complex_type': 'literal', 'value': False}`

