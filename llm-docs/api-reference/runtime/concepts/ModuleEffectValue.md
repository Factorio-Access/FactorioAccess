# ModuleEffectValue

The percentual increase of the attribute. A value of `0.6` means a 60% increase.

Quality values are multiplied by [LuaQualityPrototype::next_probability](runtime:LuaQualityPrototype::next_probability). For example, if a module's quality effect is 0.2 and the current quality's next_probability is 0.1, then the chance to get the next quality item is 2%.

**Type:** `float`

