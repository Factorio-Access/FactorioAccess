# BaseEnergySource

The abstract base of all [EnergySources](prototype:EnergySource). Specifies the way an entity gets its energy.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### emissions_per_minute

The pollution an entity emits per minute at full energy consumption. This is exactly the value that is shown in the entity tooltip.

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

### render_no_power_icon

Whether to render the "no power" icon if the entity is low on power. Also applies to the "no fuel" icon when using burner energy sources.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### render_no_network_icon

Whether to render the "no network" icon if the entity is not connected to an electric network.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

