# MineableProperties

**Type:** Table

## Parameters

### fluid_amount

The required fluid amount if any.

**Type:** `double`

**Optional:** Yes

### minable

Is this entity mineable at all?

**Type:** `boolean`

**Required:** Yes

### mining_particle

Prototype name of the particle produced when mining this entity. Will only be present if this entity produces any particle during mining.

**Type:** `string`

**Optional:** Yes

### mining_time

Energy required to mine an entity.

**Type:** `double`

**Required:** Yes

### mining_trigger

The mining trigger if any.

**Type:** Array[`TriggerItem`]

**Optional:** Yes

### products

Products obtained by mining this entity.

**Type:** Array[`Product`]

**Optional:** Yes

### required_fluid

The prototype name of the required fluid if any.

**Type:** `string`

**Optional:** Yes

### transfer_entity_health_to_products

**Type:** `boolean`

**Required:** Yes

