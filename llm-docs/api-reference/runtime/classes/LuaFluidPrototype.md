# LuaFluidPrototype

Prototype of a fluid.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### default_temperature

Default temperature of this fluid.

**Read type:** `double`

### max_temperature

Maximum temperature this fluid can reach.

**Read type:** `double`

### heat_capacity

The amount of energy in Joules required to heat one unit of this fluid by 1°C.

**Read type:** `double`

### base_color

**Read type:** `Color`

### flow_color

**Read type:** `Color`

### gas_temperature

The temperature above which this fluid will be shown as gaseous inside tanks and pipes.

**Read type:** `double`

### emissions_multiplier

A multiplier on the amount of emissions produced when this fluid is burnt in a generator. A value above `1.0` increases emissions and vice versa. The multiplier can't be negative.

**Read type:** `double`

### fuel_value

The amount of energy in Joules one unit of this fluid will produce when burnt in a generator. A value of `0` means this fluid can't be used for energy generation. The value can't be negative.

**Read type:** `double`

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaFluidPrototype`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

