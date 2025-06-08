# LuaCustomChartTag

A custom tag that shows on the map view.

## Methods

### destroy

Destroys this tag.

## Attributes

### force

**Type:** `LuaForce` _(read-only)_

The force this tag belongs to.

### icon

**Type:** `SignalID`

This tag's icon, if it has one. Writing `nil` removes it.

### last_user

**Type:** `LuaPlayer`

The player who last edited this tag.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### position

**Type:** `MapPosition` _(read-only)_

The position of this tag.

### surface

**Type:** `LuaSurface` _(read-only)_

The surface this tag belongs to.

### tag_number

**Type:** `uint` _(read-only)_

The unique ID for this tag on this force.

### text

**Type:** `string`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

