# LuaLogisticSection

Logistic section of a particular [LuaLogisticPoint](runtime:LuaLogisticPoint) or [LuaConstantCombinatorControlBehavior](runtime:LuaConstantCombinatorControlBehavior).

## Methods

### clear_slot

Clears the logistic request and auto-trash from the given slot.

This can only be called when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `slot_index` `LogisticFilterIndex`: Index of a slot to clear.

### get_slot

Gets current settings of logistic request and auto-trash from the given slot.

**Parameters:**

- `slot_index` `LogisticFilterIndex`: Index of a slot to read.

**Returns:**

- `LogisticFilter`: 

### set_slot

Sets logistic request and auto-trash slot to the given value.

This will silently fail if personal logistics are not researched yet.

This can only be called when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `filter` `LogisticFilter`: The details of the filter to set.
- `slot_index` `LogisticFilterIndex`: Index of a slot to set.

**Returns:**

- `LogisticFilterIndex`: The existing index for the given filter or nil if the filter was successfully set.

## Attributes

### active

**Type:** `boolean`

Whether this section is active. This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

### filters

**Type:** ``LogisticFilter`[]`

The logistic filters for this section.

This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

### filters_count

**Type:** `uint` _(read-only)_

Amount of filters this section has

### group

**Type:** `string`

The group this section belongs to.

An empty string when in no group.

This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

### index

**Type:** `uint` _(read-only)_

The section index of this section.

### is_manual

**Type:** `boolean` _(read-only)_

Shortcut to check whether [LuaLogisticSection::type](runtime:LuaLogisticSection::type) is equal to [manual](runtime:defines.logistic_section_type.manual).

### multiplier

**Type:** `float`

Multiplier applied to all filters before they are used by game. This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:** `LuaEntity` _(read-only)_

The [LuaEntity](runtime:LuaEntity) owner of this LuaLogisticSection.

### type

**Type:** `defines.logistic_section_type` _(read-only)_

The type of this logistic section. Sections that are not manual are controlled by game itself and may not be allowed to be changed by script.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

