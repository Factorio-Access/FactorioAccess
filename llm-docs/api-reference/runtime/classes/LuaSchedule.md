# LuaSchedule

The schedule of a particular [LuaTrain](runtime:LuaTrain) or [LuaSpacePlatform](runtime:LuaSpacePlatform).

## Attributes

### owner

The owner of this schedule.

**Read type:** `LuaTrain` | `LuaSpacePlatform`

**Optional:** Yes

### interrupt_count

**Read type:** `uint32`

### current

The schedule index of the current destination.

**Read type:** `uint32`

### tick_of_last_schedule_change

**Read type:** `MapTick`

### tick_of_last_activity

The time when the train or space platform was last considered active for the inactivity condition.

Note: when writing, value must not be larger than LuaGameScript::tick

**Read type:** `MapTick`

**Write type:** `MapTick`

### ticks_in_station

How long this train or space platform has been in the current station.

**Read type:** `MapTick`

### group

The group this schedule is part of, if any.

**Read type:** `string`

**Write type:** `string`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### add_wait_condition

Adds the given wait condition to the given record.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `condition_index` `uint32`
- `type` `WaitConditionType`

### remove_wait_condition

Removes the given wait condition from the given record.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `condition_index` `uint32`

### set_wait_condition_mode

Sets the comparison on the given wait condition.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `condition_index` `uint32`
- `mode` `string` - `"and"`, or `"or"`

### change_wait_condition

Changes the wait condition on the given record to the new values.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `condition_index` `uint32`
- `wait_condition` `WaitCondition`

### add_record

Adds the given record to the end of the current schedule or at the given index using the provided data.

**Parameters:**

- `data` `AddRecordData`

**Returns:**

- `uint32` *(optional)* - The index the record was added at.

### remove_record

Removes the record at the given record position, if the record position is valid.

**Parameters:**

- `record_position` `ScheduleRecordPosition`

### copy_record

Copies the record from the given schedule at the given index into this schedule at the given index.

**Parameters:**

- `source_schedule` `LuaSchedule`
- `source_index` `uint32`
- `destination_index` `uint32`

### add_interrupt

Adds the given interrupt to the schedule if an interrupt with the given name does not already exist.

**Parameters:**

- `interrupt` `ScheduleInterrupt`

### remove_interrupt

Removes the interrupt at the given index, if the index is valid.

**Parameters:**

- `index` `uint32`

### activate_interrupt

Activates the interrupt at the given index, if the index is valid.

**Parameters:**

- `index` `uint32`

### change_interrupt

Changes the interrupt at the given index to the provided values. Note, the names must match.

**Parameters:**

- `index` `uint32`
- `interrupt` `ScheduleInterrupt`

### rename_interrupt

**Parameters:**

- `old_name` `string` - The interrupt to rename
- `new_name` `string` - The new name - if it already exists, does nothing.

### go_to_station

Sets the train or space platform to go to a destination, including changing the train/space platform to automatic mode.

**Parameters:**

- `schedule_index` `uint32` - The schedule index

### set_stopped

Sets whether this train is in [manual mode](runtime:LuaTrain::manual_mode) or this space platform is [paused](runtime:LuaSpacePlatform::paused).

**Parameters:**

- `stopped` `boolean`

### set_allow_unloading

Sets if unloading is allowed at the given schedule record position. Only relevant for space platforms.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `allow` `boolean`

### drag_record

**Parameters:**

- `from` `uint32`
- `to` `uint32`
- `interrupt_index` `uint32` *(optional)* - The interrupt to operate on, if any.

### drag_interrupt

**Parameters:**

- `from` `uint32`
- `to` `uint32`

### drag_wait_condition

**Parameters:**

- `record_position` `ScheduleRecordPosition` - The record to change.
- `from` `uint32`
- `to` `uint32`

### get_record

**Parameters:**

- `record_position` `ScheduleRecordPosition`

**Returns:**

- `ScheduleRecord` *(optional)*

### get_records

**Parameters:**

- `interrupt_index` `uint32` *(optional)* - If provided, gets the records for this interrupt.

**Returns:**

- Array[`ScheduleRecord`] *(optional)*

### set_records

**Parameters:**

- `records` Array[`ScheduleRecord`]
- `interrupt_index` `uint32` *(optional)* - If provided, the records will be set on this interrupt.

### clear_records

**Parameters:**

- `interrupt_index` `uint32` *(optional)* - If provided, clears the records for this interrupt.

### get_interrupt

**Parameters:**

- `index` `uint32`

**Returns:**

- `ScheduleInterrupt` *(optional)*

### get_interrupts

**Returns:**

- Array[`ScheduleInterrupt`]

### set_interrupts

**Parameters:**

- `interrupts` Array[`ScheduleInterrupt`]

### clear_interrupts

Removes all interrupts.

### get_wait_condition

Gets the wait condition at the given record position if one exists.

**Parameters:**

- `record_position` `ScheduleRecordPosition`
- `condition_index` `uint32`

**Returns:**

- `WaitCondition` *(optional)*

### get_wait_conditions

Gets the wait conditions at the given record position if they exist.

**Parameters:**

- `record_position` `ScheduleRecordPosition`

**Returns:**

- Array[`WaitCondition`] *(optional)*

### get_wait_condition_count

The number of wait conditions in the given schedule record.

**Parameters:**

- `record_position` `ScheduleRecordPosition`

**Returns:**

- `uint32` *(optional)*

### get_inside_interrupt

Gets if the given interrupt can be triggered inside other interrupts.

**Parameters:**

- `interrupt_index` `uint32`

**Returns:**

- `boolean`

### set_inside_interrupt

Sets if the given interrupt can be triggered inside other interrupts.

**Parameters:**

- `interrupt_index` `uint32`
- `value` `boolean`

### get_record_count

If the given index is invalid, `nil` is returned.

**Parameters:**

- `interrupt_index` `uint32` *(optional)* - If provided, the record count in this interrupt is read.

**Returns:**

- `uint32` *(optional)*

