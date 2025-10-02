# GeneratorEquipmentPrototype

Used by [portable fusion reactor](https://wiki.factorio.com/Portable_fusion_reactor). Provides power in equipment grids. Can produce power for free or use a burner energy source.

**Parent:** [EquipmentPrototype](EquipmentPrototype.md)
**Type name:** `generator-equipment`

## Properties

### power

The power output of this equipment.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
power = "750kW"
```

### burner

If not defined, this equipment produces power for free.

**Type:** `BurnerEnergySource`

**Optional:** Yes

