# FuelCategory

Each item which has a fuel_value must have a fuel category. The fuel categories are used to allow only certain fuels to be used in [EnergySource](prototype:EnergySource).

**Parent:** [Prototype](Prototype.md)
**Type name:** `fuel-category`
**Instance limit:** 255

## Examples

```
{
  type = "fuel-category",
  name = "best-fuel"
}
```

## Properties

### fuel_value_type

**Type:** `LocalisedString`

**Optional:** Yes

**Default:** "`{"description.fuel-value"}`"

