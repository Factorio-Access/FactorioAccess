# LuaFluidPrototype

Prototype of a fluid.

**Parent:** `LuaPrototypeBase`

## Attributes

### base_color

**Type:** `Color` _(read-only)_



### default_temperature

**Type:** `double` _(read-only)_

Default temperature of this fluid.

### emissions_multiplier

**Type:** `double` _(read-only)_

A multiplier on the amount of emissions produced when this fluid is burnt in a generator. A value above `1.0` increases emissions and vice versa. The multiplier can't be negative.

### factoriopedia_alternative

**Type:** `LuaFluidPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### flow_color

**Type:** `Color` _(read-only)_



### fuel_value

**Type:** `double` _(read-only)_

The amount of energy in Joules one unit of this fluid will produce when burnt in a generator. A value of `0` means this fluid can't be used for energy generation. The value can't be negative.

### gas_temperature

**Type:** `double` _(read-only)_

The temperature above which this fluid will be shown as gaseous inside tanks and pipes.

### heat_capacity

**Type:** `double` _(read-only)_

The amount of energy in Joules required to heat one unit of this fluid by 1°C.

### max_temperature

**Type:** `double` _(read-only)_

Maximum temperature this fluid can reach.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

