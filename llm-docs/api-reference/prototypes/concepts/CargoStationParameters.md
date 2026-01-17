# CargoStationParameters

A cargo station is any entity that has the capacity to send cargo units. In Space Age those are [RocketSiloPrototype](prototype:RocketSiloPrototype), [SpacePlatformHubPrototype](prototype:SpacePlatformHubPrototype) and [CargoLandingPadPrototype](prototype:CargoLandingPadPrototype). [Cargo bays](prototype:CargoBayPrototype) may provide additional cargo hatches to cargo stations which are cargo bay connectable.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### prefer_packed_cargo_units

Packed cargo units will wait for the full order to be completed. This is useful to save rockets in rocket silos when items trickle in slowly. The platform hub has immediate access to items so false is better to allow partial fulfillments.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hatch_definitions

**Type:** Array[`CargoHatchDefinition`]

**Optional:** Yes

### giga_hatch_definitions

Big additional hatch that goes over the actual hatches.

**Type:** Array[`GigaCargoHatchDefinition`]

**Optional:** Yes

### is_input_station

If set to false, this station will not accept incoming cargo units even if it has hatches that can. (can occur through linked cargo bays)

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### is_output_station

If set to false, this station will not dispatch cargo units even if it has hatches that can. (can occur through linked cargo bays)

**Type:** `boolean`

**Optional:** Yes

**Default:** True

