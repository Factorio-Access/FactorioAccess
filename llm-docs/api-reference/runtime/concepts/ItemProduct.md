# ItemProduct

**Type:** Table

## Parameters

### affected_by_quality

**Type:** `boolean`

**Required:** Yes

### always_fresh

**Type:** `boolean`

**Optional:** Yes

### amount

Amount of the item to give. If not returned, `amount_min` and `amount_max` will be present instead.

**Type:** `uint16`

**Optional:** Yes

### amount_max

Maximum amount of the item to give. Not returned if `amount` is returned.

**Type:** `uint16`

**Optional:** Yes

### amount_min

Minimal amount of the item to give. Not returned if `amount` is returned.

**Type:** `uint16`

**Optional:** Yes

### extra_count_fraction

Probability that a craft will yield one additional product. Also applies to bonus crafts caused by productivity.

**Type:** `float`

**Optional:** Yes

### ignored_by_productivity

How much of this product is ignored by productivity.

**Type:** `uint16`

**Optional:** Yes

### ignored_by_stats

How much of this product is ignored by statistics.

**Type:** `uint16`

**Optional:** Yes

### independent_probability

A value in range `[0, 1]`. Item is only given with this probability; otherwise no product is produced.

**Type:** `double`

**Required:** Yes

### name

Prototype name of the result.

**Type:** `string`

**Required:** Yes

### percent_spoiled

**Type:** `float`

**Optional:** Yes

### quality_change

**Type:** `int8`

**Optional:** Yes

### quality_max

**Type:** `QualityID`

**Optional:** Yes

### quality_min

**Type:** `QualityID`

**Optional:** Yes

### reset_freshness_on_craft

**Type:** `boolean`

**Optional:** Yes

### shared_probability

**Type:** `SharedProbabilityDefinition`

**Required:** Yes

### type

**Type:** `"item"`

**Required:** Yes

## Examples

```
```
-- Products of the "steel-chest" recipe (an array of Product)
{{type="item", name="steel-chest", amount=1}}
```
```

```
```
-- What a custom recipe would look like that had a probability of 0.5 to return a
-- minimum amount of 1 and a maximum amount of 5
{{type="item", name="custom-item", independent_probability=0.5, amount_min=1, amount_max=5}}
```
```

