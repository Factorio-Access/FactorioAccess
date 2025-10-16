# ElectricEnergySource

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"electric"`

**Required:** Yes

### buffer_capacity

How much energy this entity can hold.

**Type:** `Energy`

**Optional:** Yes

### usage_priority

**Type:** `ElectricUsagePriority`

**Required:** Yes

### input_flow_limit

The rate at which energy can be taken, from the network, to refill the energy buffer. `0` means no transfer.

**Type:** `Energy`

**Optional:** Yes

**Default:** "Max `double` value"

### output_flow_limit

The rate at which energy can be provided, to the network, from the energy buffer. `0` means no transfer.

**Type:** `Energy`

**Optional:** Yes

**Default:** "Max `double` value"

### drain

How much energy (per second) will be continuously removed from the energy buffer. In-game, this is shown in the tooltip as "Min. [Minimum] Consumption". Applied as a constant consumption-per-tick, even when the entity has the property [active](runtime:LuaEntity::active) set to `false`.

**Type:** `Energy`

**Optional:** Yes

## Examples

```
```
energy_source = -- energy source of oil pumpjack
{
  type = "electric",
  emissions_per_minute = { pollution = 10 },
  usage_priority = "secondary-input"
}
```
```

```
```
energy_source = -- energy source of accumulator
{
  type = "electric",
  buffer_capacity = "5MJ",
  usage_priority = "tertiary",
  input_flow_limit = "300kW",
  output_flow_limit = "300kW"
}
```
```

```
```
energy_source = -- energy source of steam engine
{
  type = "electric",
  usage_priority = "secondary-output"
}
```
```

