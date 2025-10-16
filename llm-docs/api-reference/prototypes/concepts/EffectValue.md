# EffectValue

Precision is ignored beyond two decimals - `0.567` results in `0.56` and means 56% etc. Values can range from `-327.68` to `327.67`. Numbers outside of this range will wrap around.

Quality values are multiplied by [QualityPrototype::next_probability](prototype:QualityPrototype::next_probability). For example, if a module's quality effect is 0.2 and the current quality's next_probability is 0.1, then the chance to get the next quality item is 2%.

**Type:** `float`

## Examples

```
```
{speed = 0.07}  -- 7% bonus
```
```

```
```
{quality = 0.25}  -- multiplied by quality normal next_probability = 0.1 -> 2.5% bonus
```
```

