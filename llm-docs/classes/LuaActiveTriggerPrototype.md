# LuaActiveTriggerPrototype

Prototype of an Active Trigger.

**Parent:** `LuaPrototypeBase`

## Attributes

### fork_chance

**Type:** `double` _(read-only)_

The chance that a new fork will spawn after each jump [0,1]. default = 0.

### jump_delay_ticks

**Type:** `uint` _(read-only)_

The tick delay between each jump. 0 = all jumps instantaneous. default = 0.

### max_forks

**Type:** `uint` _(read-only)_

maximum number of forks allowed to spawn for the entire chain. default = infinity.

### max_forks_per_jump

**Type:** `uint` _(read-only)_

The maximum number of forks that can spawn from a single jump. default = 1.

### max_jumps

**Type:** `uint` _(read-only)_

The max number of jumps per trigger. default = 5.

### max_range

**Type:** `double` _(read-only)_

The max distance jumps are allowed to travel away from the original target. default = infinity.

### max_range_per_jump

**Type:** `double` _(read-only)_

The max length of jumps. default = 5.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

