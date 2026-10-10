# SharedProbabilityDefinition

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### min

Lower end of the range of shared roll values that will allow product to be given. Must be >= `0` and <= `max`.

**Type:** `double`

**Required:** Yes

### max

Upper end of the range of shared roll values that will allow product to be given. Must be >= `min` and <= `1`.

**Type:** `double`

**Required:** Yes

## Examples

```
```
-- What a recipe's results would look like for a probability of 0.3 to return iron and 0.7 to return copper
-- but always exactly 1 item, never no item or both items
{
  {type = "item", name = "iron-plate", amount = 1, shared_probability = {min = 0, max = 0.3}},
  {type = "item", name = "copper-plate", amount = 1, shared_probability = {min = 0.3, max = 1}},
}
```
```

