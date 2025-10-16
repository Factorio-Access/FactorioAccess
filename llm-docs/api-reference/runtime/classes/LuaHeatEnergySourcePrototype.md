# LuaHeatEnergySourcePrototype

Prototype of a heat energy source.

## Attributes

### emissions_per_joule

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. Multiplying it by energy consumption in `Watt` gives `pollution/second`.

**Read type:** Dictionary[`string`, `double`]

### render_no_network_icon

**Read type:** `boolean`

### render_no_power_icon

**Read type:** `boolean`

### max_temperature

**Read type:** `double`

### default_temperature

**Read type:** `double`

### specific_heat

**Read type:** `double`

### max_transfer

**Read type:** `double`

### min_temperature_gradient

**Read type:** `double`

### min_working_temperature

**Read type:** `double`

### minimum_glow_temperature

**Read type:** `double`

### connections

**Read type:** Array[`HeatConnection`]

### heat_buffer_prototype

**Read type:** `LuaHeatBufferPrototype`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

