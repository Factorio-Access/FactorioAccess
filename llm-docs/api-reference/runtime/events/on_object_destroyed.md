# on_object_destroyed

Called after an object is destroyed which was registered with [LuaBootstrap::register_on_object_destroyed](runtime:LuaBootstrap::register_on_object_destroyed) previously.

Depending on when a given object is destroyed, this event will be fired at the end of the current tick or at the end of the next tick. The event's timing is independent of the in-world object being destroyed.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### registration_number

**Type:** `uint64`

The number returned by [register_on_object_destroyed](runtime:LuaBootstrap::register_on_object_destroyed) to uniquely identify this object during this event.

### tick

**Type:** `uint32`

Tick the event was generated.

### type

**Type:** `defines.target_type`

Type of the object that was destroyed. Same as third value returned by [LuaBootstrap::register_on_object_destroyed](runtime:LuaBootstrap::register_on_object_destroyed)

### useful_id

**Type:** `uint64`

The [useful identifier](runtime:RegistrationTarget) of the object. Same as second value returned by [LuaBootstrap::register_on_object_destroyed](runtime:LuaBootstrap::register_on_object_destroyed)

