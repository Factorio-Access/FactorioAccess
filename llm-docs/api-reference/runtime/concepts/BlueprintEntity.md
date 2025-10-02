# BlueprintEntity

The representation of an entity inside of a blueprint.

**Type:** Table

## Parameters

### burner_fuel_inventory

Used by entities with a burner energy source.

**Type:** `BlueprintInventoryWithFilters`

**Optional:** Yes

### direction

The direction the entity is facing. Only present for entities that can face in different directions and when the entity is not facing north.

**Type:** `defines.direction`

**Optional:** Yes

### entity_number

The entity's unique identifier in the blueprint.

**Type:** `uint`

**Required:** Yes

### items

The items that the entity will request when revived, if any.

**Type:** Array[`BlueprintInsertPlan`]

**Optional:** Yes

### mirror

Whether this entity is mirrored.

**Type:** `boolean`

**Optional:** Yes

### name

The prototype name of the entity.

**Type:** `string`

**Required:** Yes

### position

The position of the entity.

**Type:** `MapPosition`

**Required:** Yes

### quality

The prototype name of the entity's quality.

**Type:** `string`

**Optional:** Yes

### tags

The entity tags of the entity, if there are any.

**Type:** `Tags`

**Optional:** Yes

### wires

Wires connected to this entity in the blueprint.

**Type:** Array[`BlueprintWire`]

**Optional:** Yes

