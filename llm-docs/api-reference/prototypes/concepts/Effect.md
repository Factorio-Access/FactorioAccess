# Effect

When applied to [modules](prototype:ModulePrototype), the resulting effect is a sum of all module effects, multiplied through calculations: `(1 + sum module effects)`, or `(0 + sum)` for productivity. Quality calculations follow their own separate logic.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### consumption

Multiplier to energy used during operation (not idle/drain use). The minimum possible sum is -80%.

**Type:** `EffectValue`

**Optional:** Yes

### speed

Modifier to crafting speed, research speed, etc. The minimum possible sum is -80%.

**Type:** `EffectValue`

**Optional:** Yes

### productivity

Multiplied against work completed, adds to the bonus results of operating. E.g. an extra crafted recipe or immediate research bonus. The minimum possible sum is 0%.

**Type:** `EffectValue`

**Optional:** Yes

### pollution

Multiplier to the pollution factor of an entity's pollution during use. The minimum possible sum is -80%.

**Type:** `EffectValue`

**Optional:** Yes

### quality

Adds a bonus chance to increase a product's quality. The minimum possible sum is 0%. The quality effect is is multiplied by [QualityPrototype::next_probability](prototype:QualityPrototype::next_probability). For example, if a module's quality effect is 0.2 and the current quality's next_probability is 0.1, then the chance to get the next quality item is 2%.

**Type:** `EffectValue`

**Optional:** Yes

## Examples

```
```
-- These are the effects of the vanilla Speed Module 3
{speed = 0.5, consumption = 0.7, quality = -0.25}
```
```

