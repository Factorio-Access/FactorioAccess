# HeatEnergySource

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"heat"`

**Required:** Yes

### max_temperature

Must be >= `default_temperature`.

**Type:** `double`

**Required:** Yes

### specific_heat

**Type:** `Energy`

**Required:** Yes

### max_transfer

**Type:** `Energy`

**Required:** Yes

### default_temperature

**Type:** `double`

**Optional:** Yes

**Default:** 15

### min_temperature_gradient

**Type:** `double`

**Optional:** Yes

**Default:** 1

### min_working_temperature

Must be >= `default_temperature` and <= `max_temperature`.

**Type:** `double`

**Optional:** Yes

**Default:** 15

### minimum_glow_temperature

**Type:** `float`

**Optional:** Yes

**Default:** 1

### pipe_covers

**Type:** `Sprite4Way`

**Optional:** Yes

### heat_pipe_covers

**Type:** `Sprite4Way`

**Optional:** Yes

### heat_picture

**Type:** `Sprite4Way`

**Optional:** Yes

### heat_glow

**Type:** `Sprite4Way`

**Optional:** Yes

### connections

May contain up to 32 connections.

**Type:** Array[`HeatConnection`]

**Optional:** Yes

### emissions_per_minute

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

