# LineTriggerItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"line"`

**Required:** Yes

### range

**Type:** `double`

**Required:** Yes

### width

**Type:** `double`

**Required:** Yes

### range_effects

**Type:** `TriggerEffect`

**Optional:** Yes

## Examples

```
```
action =
{
  type = "line",
  range = 25,
  width = 0.5,

  range_effects =
  {
    type = "create-explosion",
    entity_name = "railgun-beam"
  },

  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      type = "damage",
      damage = { amount = 100, type = "physical"}
    }
  }
}
```
```

