# LuaRocketSiloControlBehavior

Control behavior for rocket silos.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### read_mode

The items read mode for the rocket silo.

**Read type:** `defines.control_behavior.rocket_silo.read_mode`

**Write type:** `defines.control_behavior.rocket_silo.read_mode`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

