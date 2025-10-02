# BurnerEnergySource

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"burner"`

**Required:** Yes

### fuel_inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### burnt_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### smoke

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### light_flicker

**Type:** `LightFlickeringDefinition`

**Optional:** Yes

### effectivity

`1` means 100% effectivity. Must be greater than `0`. Multiplier of the energy output.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### burner_usage

**Type:** `BurnerUsageID`

**Optional:** Yes

**Default:** "fuel"

### fuel_categories

The energy source can be used with fuel from these [fuel categories](prototype:FuelCategory).

**Type:** Array[`FuelCategoryID`]

**Optional:** Yes

**Default:** "`{"chemical"}`"

### initial_fuel

**Type:** `ItemID`

**Optional:** Yes

**Default:** ""

### initial_fuel_percent

**Type:** `double`

**Optional:** Yes

**Default:** 0.25

