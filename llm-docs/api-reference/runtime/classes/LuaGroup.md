# LuaGroup

Item group or subgroup.

## Attributes

### name

**Read type:** `string`

### localised_name

Localised name of the group.

**Read type:** `LocalisedString`

### type

**Read type:** `string`

### group

The parent group.

**Read type:** `LuaGroup`

**Subclasses:** ItemSubGroup

### subgroups

Subgroups of this group.

**Read type:** Array[`LuaGroup`]

**Subclasses:** ItemGroup

### order_in_recipe

The additional order value used in recipe ordering.

**Read type:** `string`

**Subclasses:** ItemGroup

### order

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

**Read type:** `string`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

