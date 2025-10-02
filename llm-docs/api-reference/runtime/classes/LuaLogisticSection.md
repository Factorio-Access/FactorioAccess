# LuaLogisticSection

Logistic section of a particular [LuaLogisticPoint](runtime:LuaLogisticPoint) or [LuaConstantCombinatorControlBehavior](runtime:LuaConstantCombinatorControlBehavior).

## Attributes

### owner

The [LuaEntity](runtime:LuaEntity) owner of this LuaLogisticSection.

**Read type:** `LuaEntity`

### index

The section index of this section.

**Read type:** `uint`

### filters

The logistic filters for this section.

This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Read type:** Array[`LogisticFilter`]

**Write type:** Array[`LogisticFilter`]

### filters_count

Amount of filters this section has

**Read type:** `uint`

### group

The group this section belongs to.

An empty string when in no group.

This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Read type:** `string`

**Write type:** `string`

### type

The type of this logistic section. Sections that are not manual are controlled by game itself and may not be allowed to be changed by script.

**Read type:** `defines.logistic_section_type`

### is_manual

Shortcut to check whether [LuaLogisticSection::type](runtime:LuaLogisticSection::type) is equal to [manual](runtime:defines.logistic_section_type.manual).

**Read type:** `boolean`

### active

Whether this section is active. This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Read type:** `boolean`

**Write type:** `boolean`

### multiplier

Multiplier applied to all filters before they are used by game. This can only be written to when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Read type:** `float`

**Write type:** `float`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### set_slot

Sets logistic request and auto-trash slot to the given value.

This will silently fail if personal logistics are not researched yet.

This can only be called when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `filter` `LogisticFilter` - The details of the filter to set.
- `slot_index` `LogisticFilterIndex` - Index of a slot to set.

**Returns:**

- `LogisticFilterIndex` *(optional)* - The existing index for the given filter or nil if the filter was successfully set.

### get_slot

Gets current settings of logistic request and auto-trash from the given slot.

**Parameters:**

- `slot_index` `LogisticFilterIndex` - Index of a slot to read.

**Returns:**

- `LogisticFilter`

### clear_slot

Clears the logistic request and auto-trash from the given slot.

This can only be called when the section [is manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `slot_index` `LogisticFilterIndex` - Index of a slot to clear.

