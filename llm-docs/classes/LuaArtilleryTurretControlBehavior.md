# LuaArtilleryTurretControlBehavior

Control behavior for artillery turrets.

**Parent:** `LuaGenericOnOffControlBehavior`

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### read_ammo

**Type:** `boolean`

`true` if the turret will send the ammunition or fluid it contains to the circuit network.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

