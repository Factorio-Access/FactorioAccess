# LuaElectricEnergySourcePrototype

Prototype of an electric energy source.

## Attributes

### buffer_capacity

**Read type:** `double`

### usage_priority

**Read type:** `string`

### drain

**Read type:** `double`

### emissions_per_joule

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. Multiplying it by energy consumption in `Watt` gives `pollution/second`.

**Read type:** Dictionary[`string`, `double`]

### render_no_network_icon

**Read type:** `boolean`

### render_no_power_icon

**Read type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_input_flow_limit

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

### get_output_flow_limit

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double`

