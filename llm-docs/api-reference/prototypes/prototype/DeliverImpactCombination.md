# DeliverImpactCombination

**Type name:** `deliver-impact-combination`

## Examples

```
{
  type = "deliver-impact-combination",
  name = "bullet-organic",
  deliver_category = "bullet",
  impact_category = "organic",
  trigger_effect_item =
  {
    type = "play-sound",
    sound =
    {
      category = "weapon",
      variations = sound_variations("__base__/sound/bullets/bullet-impact-organic", 5, 0.3),
      aggregation = {max_count = 4, remove = true, count_already_playing = true}
    }
  }
}
```

## Properties

### type

**Type:** `"deliver-impact-combination"`

**Required:** Yes

### name

Name of the deliver impact combination.

**Type:** `string`

**Required:** Yes

### impact_category

**Type:** `string`

**Required:** Yes

### deliver_category

**Type:** `string`

**Required:** Yes

### trigger_effect_item

**Type:** `TriggerEffectItem`

**Required:** Yes

