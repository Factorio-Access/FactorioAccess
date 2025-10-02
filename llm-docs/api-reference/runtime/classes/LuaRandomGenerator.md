# LuaRandomGenerator

A deterministic random generator independent from the core games random generator that can be seeded and re-seeded at will. This random generator can be saved and loaded and will maintain its state.

Note this is entirely different from calling [math.random](libraries.html)() and you should be sure you actually want to use this over calling `math.random()`. If you aren't sure if you need to use this over calling `math.random()` then you probably don't need to use this.

## Attributes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### re_seed

Re-seeds the random generator with the given value.

Seeds that are close together will produce similar results. Seeds from 0 to 341 will produce the same results.

**Parameters:**

- `seed` `uint`

## Operators

### call

Generates a random number. If no parameters are given a number in the `[0, 1)` range is returned. If a single parameter is given a floored number in the `[1, N]` range is returned. If 2 parameters are given a floored number in the `[N1, N2]` range is returned.

