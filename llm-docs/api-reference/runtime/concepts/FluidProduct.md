# FluidProduct

**Type:** Table

## Parameters

### amount

Amount of the fluid to give. If not returned, `amount_min` and `amount_max` will be present instead.

**Type:** `double`

**Optional:** Yes

### amount_max

Maximum amount of the fluid to give. Not returned if `amount` is returned.

**Type:** `double`

**Optional:** Yes

### amount_min

Minimal amount of the fluid to give. Not returned if `amount` is returned.

**Type:** `double`

**Optional:** Yes

### fluidbox_index

**Type:** `uint32`

**Optional:** Yes

### ignored_by_productivity

How much of this product is ignored by productivity.

**Type:** `double`

**Optional:** Yes

### ignored_by_stats

How much of this product is ignored by statistics.

**Type:** `double`

**Optional:** Yes

### name

Prototype name of the result.

**Type:** `string`

**Required:** Yes

### probability

A value in range `[0, 1]`. Fluid is only given with this probability; otherwise no product is produced.

**Type:** `double`

**Required:** Yes

### temperature

The fluid temperature of this product.

**Type:** `float`

**Optional:** Yes

### type

**Type:** `"fluid"`

**Required:** Yes

## Examples

```
```
-- Products of the "advanced-oil-processing" recipe
{{type="fluid", name="heavy-oil", amount=1},
  {type="fluid", name="light-oil", amount=4.5},
  {type="fluid", name="petroleum-gas", amount=5.5}}
```
```

