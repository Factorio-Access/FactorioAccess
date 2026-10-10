# Effect

When applied to [modules](prototype:ModulePrototype), the resulting effect is a sum of all module effects, multiplied through calculations: `(1 + sum module effects)`, or `(0 + sum)` for productivity.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### consumption

Multiplier to energy used during operation (not idle/drain use). The minimum possible sum defaults to -80% and can be changed through [EffectReceiver::consumption_limits](prototype:EffectReceiver::consumption_limits) on the machine.

**Type:** `EffectValue`

**Optional:** Yes

### speed

Modifier to crafting speed, research speed, etc. The minimum possible sum defaults to -80% and can be changed through [EffectReceiver::speed_limits](prototype:EffectReceiver::speed_limits) on the machine.

**Type:** `EffectValue`

**Optional:** Yes

### productivity

Multiplied against work completed, adds to the bonus results of operating. E.g. an extra crafted recipe or immediate research bonus. The minimum possible sum defaults to -80% and can be changed through [EffectReceiver::productivity_limits](prototype:EffectReceiver::productivity_limits) on the machine.

**Type:** `EffectValue`

**Optional:** Yes

### pollution

Multiplier to the pollution factor of an entity's pollution during use. The minimum possible sum defaults to -80% and can be changed through [EffectReceiver::pollution_limits](prototype:EffectReceiver::pollution_limits) on the machine.

**Type:** `EffectValue`

**Optional:** Yes

### quality

Adds a bonus chance to increase a product's quality. The minimum possible sum defaults to 0% and can be changed through [EffectReceiver::quality_limits](prototype:EffectReceiver::quality_limits) on the machine. If negative values are allowed on the effect receiver, the product's quality can be [decreased](prototype:QualityPrototype::previous_probability).

**Type:** `EffectValue`

**Optional:** Yes

## Examples

```
```
-- These are the effects of the vanilla Speed Module 3
{speed = 0.5, consumption = 0.7, quality = -0.025}
```
```

