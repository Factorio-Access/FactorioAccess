# CargoDestination

The destination of a cargo pod.

**Type:** Table

## Parameters

### hatch

Only used if `type` is [station](runtime:defines.cargo_destination.station). Must be connected to the station and not reserved.

**Type:** `LuaCargoHatch`

**Optional:** Yes

### land_at_exact_position

Only used if `type` is [surface](runtime:defines.cargo_destination.surface) and `position` is specified. Determines whether to land at `position` exactly or at a random location nearby. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### position

Only used if `type` is [surface](runtime:defines.cargo_destination.surface). Determines the position on the surface to land near. If not provided, cargo pod will switch destination type from [surface](runtime:defines.cargo_destination.surface) to [station](runtime:defines.cargo_destination.station) before starting descent if there is a station available, and will land at {0, 0} if there is no station available.

**Type:** `MapPosition`

**Optional:** Yes

### space_platform

Only used if `type` is [space_platform](runtime:defines.cargo_destination.space_platform). Only used for sending space platform starter packs to a platform that is waiting for a starter pack.

**Type:** `LuaSpacePlatform`

**Optional:** Yes

### station

Only used if `type` is [station](runtime:defines.cargo_destination.station). Must be entity of type `cargo-landing-pad` or `space-platform-hub`.

**Type:** `LuaEntity`

**Optional:** Yes

### surface

Only used if `type` is [surface](runtime:defines.cargo_destination.surface).

**Type:** `SurfaceIdentification`

**Optional:** Yes

### transform_launch_products

Only used if `type` is [station](runtime:defines.cargo_destination.station) or [surface](runtime:defines.cargo_destination.surface). If true, items with [rocket_launch_products](prototype:ItemPrototype::rocket_launch_products) defined will be transformed into their products before starting descent. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### type

The type of destination.

**Type:** `defines.cargo_destination`

**Required:** Yes

