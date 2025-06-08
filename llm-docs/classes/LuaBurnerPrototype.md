# LuaBurnerPrototype

Prototype of a burner energy source.

## Attributes

### burnt_inventory_size

**Type:** `uint` _(read-only)_



### effectivity

**Type:** `double` _(read-only)_



### emissions_per_joule

**Type:** `dictionary<`string`, `double`>` _(read-only)_

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. Multiplying it by energy consumption in `Watt` gives `pollution/second`.

### fuel_categories

**Type:** `dictionary<`string`, `True`>` _(read-only)_

The value in the dictionary is meaningless and exists just to allow for easy lookup.

### fuel_inventory_size

**Type:** `uint` _(read-only)_



### initial_fuel

**Type:** `LuaItemPrototype` _(read-only)_



### initial_fuel_percent

**Type:** `double` _(read-only)_



### light_flicker

**Type:** `unknown` _(read-only)_

The light flicker definition for this burner prototype.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### render_no_network_icon

**Type:** `boolean` _(read-only)_



### render_no_power_icon

**Type:** `boolean` _(read-only)_



### smoke

**Type:** ``SmokeSource`[]` _(read-only)_

The smoke sources for this burner prototype.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

