# LuaGroup

Item group or subgroup.

## Attributes

### group

**Type:** `LuaGroup` _(read-only)_

The parent group.

### localised_name

**Type:** `LocalisedString` _(read-only)_

Localised name of the group.

### name

**Type:** `string` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### order

**Type:** `string` _(read-only)_

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

### order_in_recipe

**Type:** `string` _(read-only)_

The additional order value used in recipe ordering.

### subgroups

**Type:** ``LuaGroup`[]` _(read-only)_

Subgroups of this group.

### type

**Type:** `string` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

