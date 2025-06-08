# LuaLogisticSections

Logistic sections of an entity.

## Methods

### add_section

Adds a new logistic section if possible.

**Parameters:**

- `group` `string` _(optional)_: The group to assign this section to.

**Returns:**

- `LuaLogisticSection`: Logistic section if added.

### get_section

Gets section on the selected index, if it exists.

**Parameters:**

- `section_index` `uint`: Index of the section.

**Returns:**

- `LuaLogisticSection`: 

### remove_section

Removes the given logistic section if possible. Removal may fail if the section index is out of range or the section is not [manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `section_index` `uint`: Index of the section.

**Returns:**

- `boolean`: Whether section was removed.

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### sections

**Type:** ``LuaLogisticSection`[]` _(read-only)_

All logistic sections of this entity.

### sections_count

**Type:** `uint` _(read-only)_

Amount of logistic sections this entity has.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

