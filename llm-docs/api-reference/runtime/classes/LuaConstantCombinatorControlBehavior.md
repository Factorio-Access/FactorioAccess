# LuaConstantCombinatorControlBehavior

Control behavior for constant combinators.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### enabled

Turns this constant combinator on and off.

**Read type:** `boolean`

**Write type:** `boolean`

### sections

All logistic sections of this constant combinator.

**Read type:** Array[`LuaLogisticSection`]

### sections_count

Amount of logistic sections this constant combinator has.

**Read type:** `uint32`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### add_section

Adds a new logistic section to this constant combinator if possible.

**Parameters:**

- `group` `string` *(optional)* - The group to assign this section to.

**Returns:**

- `LuaLogisticSection` *(optional)* - Logistic section if added.

### remove_section

Removes the given logistic section if possible. Removal may fail if the section index is out of range or the section is not [manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `section_index` `uint32` - Index of the section.

**Returns:**

- `boolean` - Whether section was removed.

### get_section

Gets section on the selected index, if it exists.

**Parameters:**

- `section_index` `uint32` - Index of the section.

**Returns:**

- `LuaLogisticSection` *(optional)*

