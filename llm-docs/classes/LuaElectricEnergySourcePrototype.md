# LuaElectricEnergySourcePrototype

Prototype of an electric energy source.

## Methods

### get_input_flow_limit



**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_output_flow_limit



**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

## Attributes

### buffer_capacity

**Type:** `double` _(read-only)_



### drain

**Type:** `double` _(read-only)_



### emissions_per_joule

**Type:** `dictionary<`string`, `double`>` _(read-only)_

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. Multiplying it by energy consumption in `Watt` gives `pollution/second`.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### render_no_network_icon

**Type:** `boolean` _(read-only)_



### render_no_power_icon

**Type:** `boolean` _(read-only)_



### usage_priority

**Type:** `string` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

