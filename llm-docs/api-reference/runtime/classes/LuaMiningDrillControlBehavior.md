# LuaMiningDrillControlBehavior

Control behavior for mining drills.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### circuit_read_resources

`true` if this drill should send the resources in the field to the circuit network.

Which resources depends on [LuaMiningDrillControlBehavior::resource_read_mode](runtime:LuaMiningDrillControlBehavior::resource_read_mode)

**Read type:** `boolean`

**Write type:** `boolean`

### resource_read_mode

If the mining drill should send just the resources in its area or the entire field it's on to the circuit network.

**Read type:** `defines.control_behavior.mining_drill.resource_read_mode`

**Write type:** `defines.control_behavior.mining_drill.resource_read_mode`

### resource_read_targets

The resource entities that the mining drill will send information about to the circuit network or an empty array.

**Read type:** Array[`LuaEntity`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

