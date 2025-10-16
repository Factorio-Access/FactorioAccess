# MinableProperties

The mining properties of objects. For formulas for the mining time, see [mining](https://wiki.factorio.com/Mining).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### mining_time

How many seconds are required to mine this object at 1 mining speed.

**Type:** `double`

**Required:** Yes

### include_in_show_counts

**Type:** `boolean`

**Optional:** Yes

### transfer_entity_health_to_products

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### results

The items or fluids that are returned when this object is mined.

**Type:** Array[`ProductPrototype`]

**Optional:** Yes

### result

Only loaded if `results` is not defined.

Which item is dropped when this is mined. Cannot be empty. If you want the entity to not be minable, don't specify the minable properties, if you want it to be minable with no result item, don't specify the result at all.

**Type:** `ItemID`

**Optional:** Yes

### fluid_amount

The amount of fluid that is used up when this object is mined. If this is > 0, this object cannot be mined by hand.

**Type:** `FluidAmount`

**Optional:** Yes

**Default:** 0

### mining_particle

Name of a [ParticlePrototype](prototype:ParticlePrototype). Which set of particles to use.

**Type:** `ParticleID`

**Optional:** Yes

### required_fluid

Name of a [FluidPrototype](prototype:FluidPrototype). The fluid that is used up when this object is mined.

**Type:** `FluidID`

**Optional:** Yes

### count

Only loaded if `results` is not defined.

How many of result are dropped.

**Type:** `uint16`

**Optional:** Yes

**Default:** 1

### mining_trigger

**Type:** `Trigger`

**Optional:** Yes

## Examples

```
```
minable = { mining_time = 0.55, result = "wood", count = 4, mining_particle = "wooden-particle" }
```
```

```
```
minable =
{
  mining_time = 1,
  results =
  {
    {
      type = "fluid",
      name = "crude-oil",
      amount = 10
    }
  }
}
```
```

