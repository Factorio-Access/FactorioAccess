# EffectValue

Precision is ignored beyond two decimals - `0.567` results in `0.56` and means 56% etc. Values can range from `-327.68` to `327.67`. Numbers outside of this range will wrap around.

Quality values are divided by 10 internally, allowing for one more decimal of precision.

