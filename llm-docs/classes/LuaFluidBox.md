# LuaFluidBox

An array of fluid boxes of an entity. Entities may contain more than one fluid box, and some can change the number of fluid boxes -- for instance, an assembling machine will change its number of fluid boxes depending on its active recipe. See [Fluid](runtime:Fluid).

Do note that reading from a [LuaFluidBox](runtime:LuaFluidBox) creates a new table and writing will copy the given fields from the table into the engine's own fluid box structure. Therefore, the correct way to update a fluidbox of an entity is to read it first, modify the table, then write the modified table back. Directly accessing the returned table's attributes won't have the desired effect.

## Methods

### add_linked_connection

Registers a linked connection between this entity and other entity. Because entity may have multiple fluidboxes, each with multiple connections that could be linked, a unique value for this and other linked_connection_id may need to be given.

It may happen a linked connection is not established immediately due to crafting machines being possible to not have certain fluidboxes exposed at a given point in time, but once they appear (due to recipe changes that would use them) they will be linked. Linked connections are persisted as (this_entity, this_linked_connection_id, other_entity, other_linked_connection_id) so if a pipe connection definition's value of linked_connection_id changes existing connections may not restore correct connections.

Every fluidbox connection that was defined in prototypes as connection_type=="linked" may be linked to at most 1 other fluidbox. When trying to connect already used connection, previous connection will be removed.

Linked connections cannot go to the same entity even if they would be part of other fluidbox.

**Parameters:**

- `other_entity` `LuaEntity`: 
- `other_linked_connection_id` `uint`: 
- `this_linked_connection_id` `uint`: 

### flush

Flushes all fluid from this fluidbox and its fluid system.

**Parameters:**

- `fluid` `FluidID` _(optional)_: If provided, only this fluid is flushed.
- `index` `uint`: 

**Returns:**

- `dictionary<`string`, `float`>`: The removed fluid.

### get_capacity

The capacity of the given fluidbox segment.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `double`: 

### get_connections

The fluidboxes to which the fluidbox at the given index is connected.

**Parameters:**

- `index` `uint`: 

**Returns:**

- ``LuaFluidBox`[]`: 

### get_filter

Get a fluid box filter

**Parameters:**

- `index` `uint`: The index of the filter to get.

**Returns:**

- `FluidBoxFilter`: The filter at the requested index, or `nil` if there isn't one.

### get_fluid_segment_contents

Gets counts of all fluids in the fluid segment. May return `nil` for fluid wagon, fluid turret's internal buffer, or a fluidbox which does not belong to a fluid segment.

Note that this method only ever returns one fluid, since fluids can't be mixed anymore.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `dictionary<`string`, `uint`>`: The counts, indexed by fluid name.

### get_fluid_segment_id

Gets the unique ID of the fluid segment this fluid box belongs to. May return `nil` for fluid wagon, fluid turret's internal buffer or a fluidbox which does not belong to a fluid segment.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `uint`: 

### get_linked_connection

Returns other end of a linked connection.

**Parameters:**

- `this_linked_connection_id` `uint`: 

**Returns:**

- `LuaEntity`: Other entity to which a linked connection was made
- `uint`: linked_connection_id on other entity

### get_linked_connections

Returns list of all linked connections registered for this entity.

**Returns:**

- ``FluidBoxConnectionRecord`[]`: 

### get_locked_fluid

Returns the fluid the fluidbox is locked onto

**Parameters:**

- `index` `uint`: 

**Returns:**

- `string`: `nil` if the fluidbox is not locked to any fluid.

### get_pipe_connections

Get the fluid box's connections and associated data.

**Parameters:**

- `index` `uint`: 

**Returns:**

- ``PipeConnection`[]`: 

### get_prototype

The prototype of this fluidbox index. If this is used on a fluidbox of a crafting machine which due to recipe was created by merging multiple prototypes, a table of prototypes that were merged will be returned instead

**Parameters:**

- `index` `uint`: 

**Returns:**

- : 

### remove_linked_connection

Removes linked connection record. If connected, other end will be also removed.

**Parameters:**

- `this_linked_connection_id` `uint`: 

### set_filter

Set a fluid box filter.

Some entities cannot have their fluidbox filter set, notably fluid wagons and crafting machines.

**Parameters:**

- `filter` : The filter to set. Setting `nil` clears the filter.
- `index` `uint`: The index of the filter to set.

**Returns:**

- `boolean`: Whether the filter was set successfully.

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:** `LuaEntity` _(read-only)_

The entity that owns this fluidbox.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

