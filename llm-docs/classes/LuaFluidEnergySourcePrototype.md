# LuaFluidEnergySourcePrototype

Prototype of a fluid energy source.

## Attributes

### burns_fluid

**Type:** `boolean` _(read-only)_



### destroy_non_fuel_fluid

**Type:** `boolean` _(read-only)_



### effectivity

**Type:** `double` _(read-only)_



### emissions_per_joule

**Type:** `dictionary<`string`, `double`>` _(read-only)_

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. Multiplying it by energy consumption in `Watt` gives `pollution/second`.

### fluid_box

**Type:** `LuaFluidBoxPrototype` _(read-only)_

The fluid box for this energy source.

### fluid_usage_per_tick

**Type:** `double` _(read-only)_



### maximum_temperature

**Type:** `double` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### render_no_network_icon

**Type:** `boolean` _(read-only)_



### render_no_power_icon

**Type:** `boolean` _(read-only)_



### scale_fluid_usage

**Type:** `boolean` _(read-only)_



### smoke

**Type:** ``SmokeSource`[]` _(read-only)_

The smoke sources for this prototype, if any.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

