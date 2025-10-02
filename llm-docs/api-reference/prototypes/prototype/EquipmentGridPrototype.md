# EquipmentGridPrototype

The prototype of an equipment grid, for example the one used in a [power armor](https://wiki.factorio.com/Power_armor).

**Parent:** [Prototype](Prototype.md)
**Type name:** `equipment-grid`
**Instance limit:** 255

## Properties

### equipment_categories

Only [equipment](prototype:EquipmentPrototype) with at least one of these [categories](prototype:EquipmentCategory) can be inserted into the grid.

**Type:** Array[`EquipmentCategoryID`]

**Required:** Yes

### width

**Type:** `uint32`

**Required:** Yes

### height

**Type:** `uint32`

**Required:** Yes

### locked

Whether this locked from user interaction which means that the user cannot put equipment into or take equipment from this equipment grid.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

