# LuaCustomChartTag

A custom tag that shows on the map view.

## Attributes

### icon

This tag's icon, if it has one. Writing `nil` removes it.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### last_user

The player who last edited this tag.

**Read type:** `LuaPlayer`

**Write type:** `PlayerIdentification`

**Optional:** Yes

### position

The position of this tag.

**Read type:** `MapPosition`

**Write type:** `MapPosition`

### text

**Read type:** `string`

**Write type:** `string`

### tag_number

The unique ID for this tag on this force.

**Read type:** `uint32`

### force

The force this tag belongs to.

**Read type:** `LuaForce`

### surface

The surface this tag belongs to.

**Read type:** `LuaSurface`

**Write type:** `LuaSurface`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Destroys this tag.

