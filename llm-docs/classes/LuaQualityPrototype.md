# LuaQualityPrototype

Prototype of a quality.

**Parent:** `LuaPrototypeBase`

## Attributes

### beacon_power_usage_multiplier

**Type:** `float` _(read-only)_



### color

**Type:** `Color` _(read-only)_

The color of the prototype

### draw_sprite_by_default

**Type:** `boolean` _(read-only)_



### level

**Type:** `uint` _(read-only)_

Level basically specifies the stat-increasing value of this quality level

### mining_drill_resource_drain_multiplier

**Type:** `float` _(read-only)_



### next

**Type:** `LuaQualityPrototype` _(read-only)_

The next higher level of the quality

### next_probability

**Type:** `double` _(read-only)_

The probability multiplier of getting the next level of quality

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

