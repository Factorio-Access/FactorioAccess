# LuaActiveTriggerPrototype

Prototype of an Active Trigger.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### max_jumps

The max number of jumps per trigger. default = 5.

**Read type:** `uint`

### max_range_per_jump

The max length of jumps. default = 5.

**Read type:** `double`

### max_range

The max distance jumps are allowed to travel away from the original target. default = infinity.

**Read type:** `double`

### jump_delay_ticks

The tick delay between each jump. 0 = all jumps instantaneous. default = 0.

**Read type:** `uint`

### fork_chance

The chance that a new fork will spawn after each jump [0,1]. default = 0.

**Read type:** `double`

### max_forks_per_jump

The maximum number of forks that can spawn from a single jump. default = 1.

**Read type:** `uint`

### max_forks

maximum number of forks allowed to spawn for the entire chain. default = infinity.

**Read type:** `uint`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

