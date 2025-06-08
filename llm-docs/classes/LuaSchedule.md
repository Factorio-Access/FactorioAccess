# LuaSchedule

The schedule of a particular [LuaTrain](runtime:LuaTrain) or [LuaSpacePlatform](runtime:LuaSpacePlatform).

## Methods

### activate_interrupt

Activates the interrupt at the given index, if the index is valid.

**Parameters:**

- `index` `uint`: 

### add_interrupt

Adds the given interrupt to the schedule if an interrupt with the given name does not already exist.

**Parameters:**

- `interrupt` `ScheduleInterrupt`: 

### add_record

Adds the given record to the end of the current schedule or at the given index using the provided data.

**Parameters:**

- `data` `AddRecordData`: 

**Returns:**

- `uint`: The index the record was added at.

### add_wait_condition

Adds the given wait condition to the given record.

**Parameters:**

- `condition_index` `uint`: 
- `record_index` `ScheduleRecordPosition`: 
- `type` `WaitConditionType`: 

### change_interrupt

Changes the interrupt at the given index to the provided values. Note, the names must match.

**Parameters:**

- `index` `uint`: 
- `interrupt` `ScheduleInterrupt`: 

### change_wait_condition

Changes the wait condition on the given record to the new values.

**Parameters:**

- `condition_index` `uint`: 
- `record_index` `ScheduleRecordPosition`: 
- `wait_condition` `WaitCondition`: 

### clear_interrupts

Removes all interrupts.

### clear_records



**Parameters:**

- `interrupt_index` `uint` _(optional)_: If provided, clears the records for this interrupt.

### copy_record

Copies the record from the given schedule at the given index into this schedule at the given index.

**Parameters:**

- `destination_index` `uint`: 
- `source_index` `uint`: 
- `source_schedule` `LuaSchedule`: 

### drag_interrupt



**Parameters:**

- `from` `uint`: 
- `to` `uint`: 

### drag_record



**Parameters:**

- `from` `uint`: 
- `interrupt_index` `uint` _(optional)_: The interrupt to operate on, if any.
- `to` `uint`: 

### drag_wait_condition



**Parameters:**

- `from` `uint`: 
- `index` `ScheduleRecordPosition`: The record to change.
- `to` `uint`: 

### get_inside_interrupt

Gets if the given interrupt can be triggered inside other interrupts.

**Parameters:**

- `interrupt_index` `uint`: 

**Returns:**

- `boolean`: 

### get_interrupt



**Parameters:**

- `index` `uint`: 

**Returns:**

- `ScheduleInterrupt`: 

### get_interrupts



**Returns:**

- ``ScheduleInterrupt`[]`: 

### get_record



**Parameters:**

- `index` `ScheduleRecordPosition`: 

**Returns:**

- `ScheduleRecord`: 

### get_record_count

If the given index is invalid, `nil` is returned.

**Parameters:**

- `interrupt_index` `uint` _(optional)_: If provided, the record count in this interrupt is read.

**Returns:**

- `uint`: 

### get_records



**Parameters:**

- `interrupt_index` `uint` _(optional)_: If provided, gets the records for this interrupt.

**Returns:**

- ``ScheduleRecord`[]`: 

### get_wait_condition

Gets the wait condition at the given index if one exists.

**Parameters:**

- `condition_index` `uint`: 
- `schedule_index` `ScheduleRecordPosition`: 

**Returns:**

- `WaitCondition`: 

### get_wait_condition_count

The number of wait conditions in the given schedule record.

**Parameters:**

- `index` `ScheduleRecordPosition`: 

**Returns:**

- `uint`: 

### get_wait_conditions

Gets the wait conditions at the given index if they exist.

**Parameters:**

- `schedule_index` `ScheduleRecordPosition`: 

**Returns:**

- ``WaitCondition`[]`: 

### go_to_station



**Parameters:**

- `schedule_index` `uint`: The schedule index

### remove_interrupt

Removes the interrupt at the given index, if the index is valid.

**Parameters:**

- `index` `uint`: 

### remove_record

Removes the record at the given index, if the index is valid.

**Parameters:**

- `index` `ScheduleRecordPosition`: 

### remove_wait_condition

Removes the given wait condition from the given record.

**Parameters:**

- `condition_index` `uint`: 
- `record_index` `ScheduleRecordPosition`: 

### rename_interrupt



**Parameters:**

- `new_name` `string`: The new name - if it already exists, does nothing.
- `old_name` `string`: The interrupt to rename

### set_allow_unloading

Sets if unloading is allowed at the given schedule index.

**Parameters:**

- `allow` `boolean`: 
- `index` `ScheduleRecordPosition`: 

### set_inside_interrupt

Sets if the given interrupt can be triggered inside other interrupts.

**Parameters:**

- `interrupt_index` `uint`: 
- `value` `boolean`: 

### set_interrupts



**Parameters:**

- `interrupts` ``ScheduleInterrupt`[]`: 

### set_records



**Parameters:**

- `interrupt_index` `uint` _(optional)_: If provided, the records will be set on this interrupt.
- `records` ``ScheduleRecord`[]`: 

### set_stopped



**Parameters:**

- `stopped` `boolean`: 

### set_wait_condition_mode

Sets the comparison on the given wait condition.

**Parameters:**

- `condition_index` `uint`: 
- `mode` `string`: `"and"`, or `"or"`
- `record_index` `ScheduleRecordPosition`: 

## Attributes

### current

**Type:** `uint` _(read-only)_



### group

**Type:** `string`

The group this schedule is part of, if any.

### interrupt_count

**Type:** `uint` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:**  _(read-only)_

The owner of this schedule.

### tick_of_last_activity

**Type:** `MapTick`

Note: when writing, value must not be larger than LuaGameScript::tick

### tick_of_last_schedule_change

**Type:** `MapTick` _(read-only)_



### ticks_in_station

**Type:** `MapTick` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

