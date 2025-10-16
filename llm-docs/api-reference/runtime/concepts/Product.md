# Product

Returns one of the subtypes, depending on the value of `type`.

**Type:** `ItemProduct` | `FluidProduct`

## Examples

```
```
-- Products of the "steel-chest" recipe (an array of Product)
{{type="item", name="steel-chest", amount=1}}
```
```

```
```
-- Products of the "advanced-oil-processing" recipe
{{type="fluid", name="heavy-oil", amount=1},
  {type="fluid", name="light-oil", amount=4.5},
  {type="fluid", name="petroleum-gas", amount=5.5}}
```
```

```
```
-- What a custom recipe would look like that had a probability of 0.5 to return a
-- minimum amount of 1 and a maximum amount of 5
{{type="item", name="custom-item", probability=0.5, amount_min=1, amount_max=5}}
```
```

