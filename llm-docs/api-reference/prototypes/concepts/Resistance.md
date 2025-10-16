# Resistance

Resistances to certain types of attacks from enemy, and physical damage. See [Damage](https://wiki.factorio.com/Damage).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `DamageTypeID`

**Required:** Yes

### decrease

The [flat resistance](https://wiki.factorio.com/Damage#Decrease.2C_or_.22flat.22_resistance) to the given damage type. (Higher is better)

**Type:** `float`

**Optional:** Yes

**Default:** 0

### percent

The [percentage resistance](https://wiki.factorio.com/Damage#Percentage_resistance) to the given damage type. (Higher is better)

**Type:** `float`

**Optional:** Yes

**Default:** 0

## Examples

```
```
resistances =
{
  {
    type = "physical",
    decrease = 6,
    percent = 30
  },
  {
    type = "explosion",
    decrease = 20,
    percent = 30
  },
  {
    type = "acid",
    decrease = 3,
    percent = 30
  },
  {
    type = "fire",
    decrease = 0,
    percent = 30
  }
}
```
```

