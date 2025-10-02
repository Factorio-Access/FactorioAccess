# AutoplaceSpecification

Specifies how probability and richness are calculated when placing something on the map.

**Type:** Table

## Parameters

### control

Control prototype name.

**Type:** `string`

**Optional:** Yes

### default_enabled

**Type:** `boolean`

**Required:** Yes

### force

**Type:** `string`

**Required:** Yes

### order

**Type:** `string`

**Required:** Yes

### placement_density

**Type:** `uint`

**Required:** Yes

### probability_expression

**Type:** `NoiseExpressionSourceString`

**Required:** Yes

### richness_expression

**Type:** `NoiseExpressionSourceString`

**Optional:** Yes

### tile_restriction

**Type:** Array[`AutoplaceSpecificationRestriction`]

**Optional:** Yes

